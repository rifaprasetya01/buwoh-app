import { Router, Request, Response } from 'express';
import authRoutes from '../modules/auth/auth.routes';
import userRoutes from '../modules/users/user.routes';
import eventsRoutes from '../modules/events/events.routes';
import invitationsRoutes from '../modules/invitations/invitations.routes';
import historyRoutes from '../modules/history/history.routes';

const router = Router();

router.use('/auth', authRoutes);
router.use('/user', userRoutes);
router.use('/events', eventsRoutes);
router.use('/invitations', invitationsRoutes);
router.use('/history', historyRoutes);

router.get('/ping', (req: Request, res: Response) => {
  res.json({ message: 'pong' });
});

export default router;
