"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_routes_1 = __importDefault(require("../modules/auth/auth.routes"));
const user_routes_1 = __importDefault(require("../modules/users/user.routes"));
const events_routes_1 = __importDefault(require("../modules/events/events.routes"));
const invitations_routes_1 = __importDefault(require("../modules/invitations/invitations.routes"));
const history_routes_1 = __importDefault(require("../modules/history/history.routes"));
const router = (0, express_1.Router)();
router.use('/auth', auth_routes_1.default);
router.use('/user', user_routes_1.default);
router.use('/events', events_routes_1.default);
router.use('/invitations', invitations_routes_1.default);
router.use('/history', history_routes_1.default);
router.get('/ping', (req, res) => {
    res.json({ message: 'pong' });
});
exports.default = router;
