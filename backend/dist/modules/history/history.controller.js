"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.HistoryController = void 0;
const history_service_1 = require("./history.service");
class HistoryController {
    static async getHistory(req, res) {
        try {
            const guestId = req.user.id;
            const filter = req.query.filter;
            const data = await history_service_1.HistoryService.getHistory(guestId, filter);
            res.status(200).json({ data });
        }
        catch (error) {
            res.status(500).json({ message: 'Error fetching history', error: error.message });
        }
    }
    static async getHistoryDetails(req, res) {
        try {
            const guestId = req.user.id;
            const historyId = req.params.historyId;
            const details = await history_service_1.HistoryService.getHistoryDetails(historyId, guestId);
            res.status(200).json(details);
        }
        catch (error) {
            if (error.message === 'History record not found') {
                res.status(404).json({ message: error.message });
            }
            else {
                res.status(500).json({ message: 'Error fetching history details', error: error.message });
            }
        }
    }
}
exports.HistoryController = HistoryController;
