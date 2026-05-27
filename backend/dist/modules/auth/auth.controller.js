"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthController = void 0;
const auth_service_1 = require("./auth.service");
class AuthController {
    static async register(req, res) {
        try {
            const user = await auth_service_1.AuthService.register(req.body);
            res.status(201).json({
                message: 'Registration successful',
                user,
            });
        }
        catch (error) {
            if (error.message === 'Email already registered') {
                res.status(409).json({ message: error.message });
            }
            else {
                res.status(500).json({ message: 'Internal server error', error: error.message });
            }
        }
    }
    static async login(req, res) {
        try {
            const data = await auth_service_1.AuthService.login(req.body);
            res.status(200).json(data);
        }
        catch (error) {
            if (error.message === 'Invalid email or password') {
                res.status(401).json({ message: error.message });
            }
            else {
                res.status(500).json({ message: 'Internal server error', error: error.message });
            }
        }
    }
    static async logout(req, res) {
        // Since JWT is stateless, logout is typically handled client-side by dropping the token.
        // If we wanted to, we could implement a token blacklist here.
        res.status(200).json({ message: 'Logged out successfully' });
    }
}
exports.AuthController = AuthController;
