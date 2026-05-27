"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.InvitationsController = void 0;
const invitations_service_1 = require("./invitations.service");
class InvitationsController {
    static async listInvitations(req, res) {
        try {
            const guestId = req.user.id;
            const search = req.query.search;
            const type = req.query.type;
            const invitations = await invitations_service_1.InvitationsService.listInvitations(guestId, search, type);
            res.status(200).json({ data: invitations });
        }
        catch (error) {
            res.status(500).json({ message: 'Error fetching invitations', error: error.message });
        }
    }
    static async getInvitationDetails(req, res) {
        try {
            const eventId = req.params.eventId;
            const details = await invitations_service_1.InvitationsService.getInvitationDetails(eventId);
            res.status(200).json(details);
        }
        catch (error) {
            if (error.message === 'Event not found') {
                res.status(404).json({ message: error.message });
            }
            else {
                res.status(500).json({ message: 'Error fetching invitation details', error: error.message });
            }
        }
    }
    static async submitBuwoh(req, res) {
        try {
            const guestId = req.user.id;
            const eventId = req.params.eventId;
            const result = await invitations_service_1.InvitationsService.submitBuwoh(eventId, guestId, req.body);
            res.status(201).json(result);
        }
        catch (error) {
            if (error.message.includes('already submitted')) {
                res.status(409).json({ message: error.message });
            }
            else {
                res.status(500).json({ message: 'Error submitting buwoh', error: error.message });
            }
        }
    }
}
exports.InvitationsController = InvitationsController;
