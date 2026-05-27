import { Response } from 'express';
import { AuthenticatedRequest } from '../../middlewares/auth.middleware';
import { EventsService } from './events.service';

export class EventsController {
  static async listHostedEvents(req: AuthenticatedRequest, res: Response) {
    try {
      const hostId = req.user!.id;
      const status = req.query.status as string;
      const events = await EventsService.listHostedEvents(hostId, status);
      res.status(200).json({ data: events });
    } catch (error: any) {
      res.status(500).json({ message: 'Error fetching hosted events', error: error.message });
    }
  }

  static async createEvent(req: AuthenticatedRequest, res: Response) {
    try {
      const hostId = req.user!.id;
      const bodyData = req.body;
      const coverImageUrl = req.file ? `/uploads/events/${req.file.filename}` : undefined;
      const newEvent = await EventsService.createEvent(hostId, bodyData, coverImageUrl);

      res.status(201).json({
        message: 'Event created successfully',
        event: newEvent,
      });
    } catch (error: any) {
      res.status(500).json({ message: 'Error creating event', error: error.message });
    }
  }

  static async getEventRecap(req: AuthenticatedRequest, res: Response) {
    try {
      const hostId = req.user!.id;
      const eventId = req.params.eventId as string;
      const recap = await EventsService.getEventRecap(eventId, hostId);
      res.status(200).json(recap);
    } catch (error: any) {
      res.status(500).json({ message: 'Error fetching event recap', error: error.message });
    }
  }

  static async listEventGuests(req: AuthenticatedRequest, res: Response) {
    try {
      const hostId = req.user!.id;
      const eventId = req.params.eventId as string;
      const status = req.query.status as string;
      const guests = await EventsService.listEventGuests(eventId, hostId, status);
      res.status(200).json({ data: guests });
    } catch (error: any) {
      res.status(500).json({ message: 'Error fetching guests', error: error.message });
    }
  }

  static async updateGuestStatus(req: AuthenticatedRequest, res: Response) {
    try {
      const hostId = req.user!.id;
      const eventId = req.params.eventId as string;
      const guestId = req.params.guestId as string;
      const result = await EventsService.updateGuestStatus(eventId, guestId, hostId, req.body);
      res.status(200).json(result);
    } catch (error: any) {
      res.status(500).json({ message: 'Error updating guest status', error: error.message });
    }
  }

  static async listReturnFavorEvents(req: AuthenticatedRequest, res: Response) {
    try {
      const userId = req.user!.id;
      const events = await EventsService.listReturnFavorEvents(userId);
      res.status(200).json({ data: events });
    } catch (error: any) {
      res.status(500).json({ message: 'Error fetching return favor events', error: error.message });
    }
  }

  static async addManualGuest(req: AuthenticatedRequest, res: Response) {
    try {
      const hostId = req.user!.id;
      const eventId = req.params.eventId as string;
      const result = await EventsService.addManualGuest(eventId, hostId, req.body);
      res.status(201).json(result);
    } catch (error: any) {
      res.status(500).json({ message: 'Gagal menambahkan tamu secara manual', error: error.message });
    }
  }
}
