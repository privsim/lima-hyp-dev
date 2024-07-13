package main

import (
    "crypto/x509"
    "encoding/pem"
    "io/ioutil"
    "log"
    "net/http"
    "os"
    "path/filepath"

    "github.com/hyperledger/fabric-gateway/pkg/client"
    "github.com/hyperledger/fabric-gateway/pkg/identity"
)

// Struct for asset
type Asset struct {
    ID    string `json:"id"`
    Value string `json:"value"`
}

func main() {
    log.SetFlags(log.LstdFlags | log.Lshortfile)

    walletPath := filepath.Join("..", "wallet")
    os.Setenv("DISCOVERY_AS_LOCALHOST", "true")

    ccpPath := filepath.Join("..", "gateway", "connection-org1.yaml")

    certPath := filepath.Join(walletPath, "user", "signcerts", "cert.pem")
    certPEM, err := ioutil.ReadFile(certPath)
    if err != nil {
        log.Fatalf("Failed to read certificate: %v", err)
    }

    block, _ := pem.Decode(certPEM)
    if block == nil {
        log.Fatalf("Failed to decode PEM block containing the certificate")
    }

    cert, err := x509.ParseCertificate(block.Bytes)
    if err != nil {
        log.Fatalf("Failed to parse certificate: %v", err)
    }

    keyPath := filepath.Join(walletPath, "user", "keystore", "key.pem")
    keyPEM, err := ioutil.ReadFile(keyPath)
    if err != nil {
        log.Fatalf("Failed to read private key: %v", err)
    }

    id, err := identity.NewX509Identity("Org1MSP", cert)
    if err != nil {
        log.Fatalf("Failed to create X509 identity: %v", err)
    }

    gateway, err := client.Connect(
        id,
        client.WithConfig(ccpPath),
    )
    if err != nil {
        log.Fatalf("Failed to connect to gateway: %v", err)
    }
    defer gateway.Close()

    network := gateway.GetNetwork("mychannel")
    contract := network.GetContract("fabcar")

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
