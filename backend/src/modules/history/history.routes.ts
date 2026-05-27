import { Router } from 'express';
import { HistoryController } from './history.controller';
import { authenticateToken } from '../../middlewares/auth.middleware';

const router = Router();

router.use(authenticateToken);

router.get('/', HistoryController.getHistory);
router.get('/:historyId', HistoryController.getHistoryDetails);

export default router;
