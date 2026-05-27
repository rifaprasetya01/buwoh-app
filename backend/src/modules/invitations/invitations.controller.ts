import { Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import { InvitationsService } from './invitations.service';

export class InvitationsController {
  static async listInvitations(req: AuthenticatedRequest, res: Response) {
    try {
      const guestId = req.user!.id;
      const search = req.query.search as string;
      const type = req.query.type as string;
      
      const invitations = await InvitationsService.listInvitations(guestId, search, type);
      res.status(200).json({ data: invitations });
    } catch (error: any) {
      res.status(500).json({ message: 'Error fetching invitations', error: error.message });
    }
  }

  static async getInvitationDetails(req: AuthenticatedRequest, res: Response) {
    try {
      const eventId = req.params.eventId as string;
      const details = await InvitationsService.getInvitationDetails(eventId);
      res.status(200).json(details);
    } catch (error: any) {
      if (error.message === 'Event not found') {
        res.status(404).json({ message: error.message });
      } else {
        res.status(500).json({ message: 'Error fetching invitation details', error: error.message });
      }
    }
  }

  static async submitBuwoh(req: AuthenticatedRequest, res: Response) {
    try {
      const guestId = req.user!.id;
      const eventId = req.params.eventId as string;
      const result = await InvitationsService.submitBuwoh(eventId, guestId, req.body);
      res.status(201).json(result);
    } catch (error: any) {
      if (error.message.includes('already submitted')) {
        res.status(409).json({ message: error.message });
      } else {
        res.status(500).json({ message: 'Error submitting buwoh', error: error.message });
      }
    }
  }
  static async getMyBuwoh(req: AuthenticatedRequest, res: Response) {
    try {
      const guestId = req.user!.id;
      const eventId = req.params.eventId as string;
      const result = await InvitationsService.getMyBuwoh(eventId, guestId);
      res.status(200).json(result);
    } catch (error: any) {
      if (error.message === 'Submission not found') {
        res.status(404).json({ message: error.message });
      } else {
        res.status(500).json({ message: 'Error fetching my buwoh', error: error.message });
      }
    }
  }

  static async updateBuwoh(req: AuthenticatedRequest, res: Response) {
    try {
      const guestId = req.user!.id;
      const eventId = req.params.eventId as string;
      const result = await InvitationsService.updateBuwoh(eventId, guestId, req.body);
      res.status(200).json(result);
    } catch (error: any) {
      if (error.message === 'Event not found or inactive' || error.message === 'Submission not found') {
        res.status(404).json({ message: error.message });
      } else if (error.message.includes('Cannot edit') || error.message.includes('past the event date')) {
        res.status(400).json({ message: error.message });
      } else {
        res.status(500).json({ message: 'Error updating buwoh', error: error.message });
      }
    }
  }
}
