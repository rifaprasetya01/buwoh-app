"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.EventsController = void 0;
const events_service_1 = require("./events.service");
class EventsController {
    static async listHostedEvents(req, res) {
        try {
            const hostId = req.user.id;
            const status = req.query.status;
            const events = await events_service_1.EventsService.listHostedEvents(hostId, status);
            res.status(200).json({ data: events });
        }
        catch (error) {
            res.status(500).json({ message: 'Error fetching hosted events', error: error.message });
        }
    }
    static async createEvent(req, res) {
        try {
            const hostId = req.user.id;
            let bodyData = req.body;
            if (typeof bodyData.address === 'string') {
                try {
                    bodyData.address = JSON.parse(bodyData.address);
                }
                catch (e) { }
            }
            if (typeof bodyData.expectedContributions === 'string') {
                try {
                    bodyData.expectedContributions = JSON.parse(bodyData.expectedContributions);
                }
                catch (e) { }
            }
            const coverImageUrl = req.file ? `/uploads/events/${req.file.filename}` : undefined;
            const newEvent = await events_service_1.EventsService.createEvent(hostId, bodyData, coverImageUrl);
            res.status(201).json({
                message: 'Event created successfully',
                event: newEvent,
            });
        }
        catch (error) {
            res.status(500).json({ message: 'Error creating event', error: error.message });
        }
    }
    static async getEventRecap(req, res) {
        try {
            const hostId = req.user.id;
            const eventId = req.params.eventId;
            const recap = await events_service_1.EventsService.getEventRecap(eventId, hostId);
            res.status(200).json(recap);
        }
        catch (error) {
            res.status(500).json({ message: 'Error fetching event recap', error: error.message });
        }
    }
    static async listEventGuests(req, res) {
        try {
            const hostId = req.user.id;
            const eventId = req.params.eventId;
            const status = req.query.status;
            const guests = await events_service_1.EventsService.listEventGuests(eventId, hostId, status);
            res.status(200).json({ data: guests });
        }
        catch (error) {
            res.status(500).json({ message: 'Error fetching guests', error: error.message });
        }
    }
    static async updateGuestStatus(req, res) {
        try {
            const hostId = req.user.id;
            const eventId = req.params.eventId;
            const guestId = req.params.guestId;
            const result = await events_service_1.EventsService.updateGuestStatus(eventId, guestId, hostId, req.body);
            res.status(200).json(result);
        }
        catch (error) {
            res.status(500).json({ message: 'Error updating guest status', error: error.message });
        }
    }
}
exports.EventsController = EventsController;
