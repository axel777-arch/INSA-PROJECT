import express from 'express';

import messagingRoutes from './modules/messaging/messaging.routes';
import { matchFarmers } from './services/targeting/targeting.controller';
import { handleUssdCallback } from './services/ussd/ussd.controller';

const app = express();

app.use(express.json());

app.post('/api/ussd', handleUssdCallback);
app.use('/api/messaging', messagingRoutes);
app.post('/api/targeting/match', matchFarmers);

export default app;
