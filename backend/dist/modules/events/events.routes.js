"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const events_controller_1 = require("./events.controller");
const auth_middleware_1 = require("../../middlewares/auth.middleware");
const validate_middleware_1 = require("../../middlewares/validate.middleware");
const events_schema_1 = require("./events.schema");
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
// Specific upload config for events
const uploadDir = 'uploads/events';
if (!fs_1.default.existsSync(uploadDir)) {
    fs_1.default.mkdirSync(uploadDir, { recursive: true });
}
const storage = multer_1.default.diskStorage({
    destination: (req, file, cb) => cb(null, uploadDir),
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path_1.default.extname(file.originalname));
    },
});
const uploadEventCover = (0, multer_1.default)({ storage });
const router = (0, express_1.Router)();
router.use(auth_middleware_1.authenticateToken);
// Host views
router.get('/', events_controller_1.EventsController.listHostedEvents);
router.post('/', uploadEventCover.single('coverImage'), (0, validate_middleware_1.validate)(events_schema_1.createEventSchema), events_controller_1.EventsController.createEvent);
router.get('/:eventId/recap', events_controller_1.EventsController.getEventRecap);
// Guest management by Host
router.get('/:eventId/guests', events_controller_1.EventsController.listEventGuests);
router.patch('/:eventId/guests/:guestId/status', (0, validate_middleware_1.validate)(events_schema_1.updateGuestStatusSchema), events_controller_1.EventsController.updateGuestStatus);
exports.default = router;
