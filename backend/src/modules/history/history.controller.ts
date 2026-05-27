import { Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import { HistoryService } from './history.service';

export class HistoryController {
  static async getHistory(req: AuthenticatedRequest, res: Response) {
    try {
      const guestId = req.user!.id;
      const filter = req.query.filter as string;
      const data = await HistoryService.getHistory(guestId, filter);
      res.status(200).json({ data });
    } catch (error: any) {
      res.status(500).json({ message: 'Error fetching history', error: error.message });
    }
  }

  static async getHistoryDetails(req: AuthenticatedRequest, res: Response) {
    try {
      const guestId = req.user!.id;
      const historyId = req.params.historyId as string;
      const details = await HistoryService.getHistoryDetails(historyId, guestId);
      res.status(200).json(details);
    } catch (error: any) {
      if (error.message === 'History record not found') {
        res.status(404).json({ message: error.message });
      } else {
        res.status(500).json({ message: 'Error fetching history details', error: error.message });
      }
    }
  }
}
