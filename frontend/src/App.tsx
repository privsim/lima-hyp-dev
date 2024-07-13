import React, { useState } from 'react';
import axios from 'axios';

const App: React.FC = () => {
    const [assetID, setAssetID] = useState<string>('');
    const [assetValue, setAssetValue] = useState<string>('');
    const [queryResult, setQueryResult] = useState<string>('');

    const createAsset = async () => {
        await axios.post('/createAsset', { id: assetID, value: assetValue });
    };

    const queryAsset = async () => {
        const response = await axios.get(`/queryAsset?id=${assetID}`);
        setQueryResult(response.data);
    };

    return (
        <div>
            <h1>Hyperledger Fabric App</h1>
            <div>
                <input
                    type="text"
                    placeholder="Asset ID"
                    value={assetID}
                    onChange={(e) => setAssetID(e.target.value)}
                />
                <input
                    type="text"
                    placeholder="Asset Value"
                    value={assetValue}
                    onChange={(e) => setAssetValue(e.target.value)}
                />
                <button onClick={createAsset}>Create Asset</button>
                <button onClick={queryAsset}>Query Asset</button>
            </div>
            <div>
                <h2>Query Result</h2>
                <p>{queryResult}</p>
            </div>
        </div>
    );
};

export default App;
