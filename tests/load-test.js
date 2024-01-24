import http from 'k6/http';
import { sleep } from 'k6';
import { uuidv4 } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';


const PORT = 100;
const URL = `http://162.19.109.236/metrics`;


export const options = {
    scenarios: {
        contacts: {
            executor: 'ramping-arrival-rate',
            preAllocatedVUs: 4000,
            timeUnit: '1s',
            startRate: 50,
            stages: [
                { target: 200, duration: '30s' }, // linearly go from 50 iters/s to 200 iters/s for 30s
                { target: 1000, duration: '0' }, // instantly jump to 500 iters/s
                { target: 300, duration: '5m' }, // continue with 500 iters/s for 10 minutes
            ],
        },
    },
};




export default function() {
    const body = {
        tracker: {
            TRACKER_ID: 1,
            WINDOW_LOCATION_HREF: "https://polytech.univ-cotedazur.fr/ecole/association-alumni",
            USER_AGENT: "Mozilla/5.0",
            PLATFORM: "Windows 11 Pro x64",
            TIMEZONE: "UTC+01:00"
        }
    }
    const exec_id = http.post(URL, body);
}