import { Router } from 'express';
import { InvitationsController } from './invitations.controller';
import { authenticateToken } from '../../middlewares/auth.middleware';
import { validate } from '../../middlewares/validate.middleware';
import { submitBuwohSchema } from './invitations.schema';

const router = Router();

router.use(authenticateToken);

router.get('/', InvitationsController.listInvitations);
router.get('/:eventId', InvitationsController.getInvitationDetails);
router.get('/:eventId/my-buwoh', InvitationsController.getMyBuwoh);
router.post('/:eventId/buwoh', validate(submitBuwohSchema), InvitationsController.submitBuwoh);
router.put('/:eventId/buwoh', validate(submitBuwohSchema), InvitationsController.updateBuwoh);

export default router;
