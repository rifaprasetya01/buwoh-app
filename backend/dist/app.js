"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const cors_1 = __importDefault(require("cors"));
const path_1 = __importDefault(require("path"));
const app = (0, express_1.default)();
// Middlewares
app.use((0, cors_1.default)());
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
// Serve static files (uploads)
app.use('/uploads', express_1.default.static(path_1.default.join(__dirname, '../uploads')));
// Health Check
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'OK', message: 'BuwohApp API is running' });
});
const routes_1 = __importDefault(require("./routes"));
// Module Routes will be imported here
app.use('/api/v1', routes_1.default);
// app.use('/api/v1/user', userRoutes);
// ...
// 404 Handler
app.use((req, res) => {
    res.status(404).json({ error: 'Endpoint not found' });
});
exports.default = app;
