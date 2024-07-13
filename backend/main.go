package main

import (
    "github.com/hyperledger/fabric-sdk-go/pkg/gateway"
    "log"
    "net/http"
    "encoding/json"
    "path/filepath"
    "os"
)

// Struct for asset
type Asset struct {
    ID    string `json:"id"`
    Value string `json:"value"`
}

func main() {
    // Setup log
    log.SetFlags(log.LstdFlags | log.Lshortfile)

    // Define wallet path
    walletPath := filepath.Join("..", "wallet")
    os.Setenv("DISCOVERY_AS_LOCALHOST", "true")

    // Create a new file system wallet for managing identities.
    wallet, err := gateway.NewFileSystemWallet(walletPath)
    if err != nil {
        log.Fatalf("Failed to create wallet: %v", err)
    }

    if !wallet.Exists("appUser") {
        log.Fatalln("An identity for the user 'appUser' does not exist in the wallet")
    }

    // Load connection profile
    ccpPath := filepath.Join("..", "gateway", "connection-org1.yaml")

    // Create a new gateway connection
    gw, err := gateway.Connect(
        gateway.WithConfig(gateway.ConfigOption(filepath.Clean(ccpPath))),
        gateway.WithIdentity(wallet, "appUser"),
    )
    if err != nil {
        log.Fatalf("Failed to connect to gateway: %v", err)
    }
    defer gw.Close()

    // Get network channel
    network, err := gw.GetNetwork("mychannel")
    if err != nil {
        log.Fatalf("Failed to get network: %v", err)
    }

    // Get contract
    contract := network.GetContract("fabcar")

    // HTTP Handlers
    http.HandleFunc("/queryAsset", func(w http.ResponseWriter, r *http.Request) {
        id := r.URL.Query().Get("id")
        result, err := contract.EvaluateTransaction("QueryAsset", id)
        if err != nil {
            http.Error(w, err.Error(), http.StatusInternalServerError)
            return
        }

        w.Header().Set("Content-Type", "application/json")
        w.Write(result)
    })

    http.HandleFunc("/createAsset", func(w http.ResponseWriter, r *http.Request) {
        var asset Asset
        if err := json.NewDecoder(r.Body).Decode(&asset); err != nil {
            http.Error(w, err.Error(), http.StatusBadRequest)
            return
        }

        _, err := contract.SubmitTransaction("CreateAsset", asset.ID, asset.Value)
        if err != nil {
            http.Error(w, err.Error(), http.StatusInternalServerError)
            return
        }

        w.WriteHeader(http.StatusCreated)
    })

    log.Println("Starting server on :8080...")
    log.Fatal(http.ListenAndServe(":8080", nil))
}
