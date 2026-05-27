import { Router } from 'express';
import { EventsController } from './events.controller';
import { authenticateToken } from '../../middlewares/auth.middleware';
import { validate } from '../../middlewares/validate.middleware';
import { createEventSchema, updateGuestStatusSchema, addManualGuestSchema } from './events.schema';
import multer from 'multer';
import path from 'path';
import fs from 'fs';

// Specific upload config for events
const uploadDir = 'uploads/events';
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadDir),
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  },
});
const uploadEventCover = multer({ storage });

const router = Router();

router.use(authenticateToken);

// Host views
router.get('/', EventsController.listHostedEvents);
router.get('/return-favor', EventsController.listReturnFavorEvents);
router.post('/', uploadEventCover.single('coverImage'), validate(createEventSchema), EventsController.createEvent);
router.get('/:eventId/recap', EventsController.getEventRecap);

// Guest management by Host
router.get('/:eventId/guests', EventsController.listEventGuests);
router.patch('/:eventId/guests/:guestId/status', validate(updateGuestStatusSchema), EventsController.updateGuestStatus);
router.post('/:eventId/guests', validate(addManualGuestSchema), EventsController.addManualGuest);

export default router;
