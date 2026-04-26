/**
 * Comprehensive API Test Script — Platform Buwoh
 * Tests all endpoints sequentially
 */

const BASE = 'http://localhost:3000/api/v1';

// Helper: make HTTP request
async function request(method, path, body = null, token = null) {
  const url = `${BASE}${path}`;
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const opts = { method, headers };
  if (body) opts.body = JSON.stringify(body);

  const res = await fetch(url, opts);
  const data = await res.json().catch(() => null);
  return { status: res.status, data };
}

// Test runner
let passed = 0;
let failed = 0;

function assert(testName, condition, detail = '') {
  if (condition) {
    console.log(`  ✅ ${testName}`);
    passed++;
  } else {
    console.log(`  ❌ ${testName} ${detail}`);
    failed++;
  }
}

async function runTests() {
  console.log('\n══════════════════════════════════════════');
  console.log('  🧪 BUWOH API — COMPREHENSIVE TEST SUITE');
  console.log('══════════════════════════════════════════\n');

  let tokenUserA, tokenUserB, userA, userB;
  let eventId, guestId;

  // ═══ 1. HEALTH CHECK ═══
  console.log('📌 1. Health Check');
  {
    const r = await request('GET', '/health');
    assert('GET /health → 200', r.status === 200);
    assert('Response has success=true', r.data?.success === true);
  }

  // ═══ 2. AUTH — REGISTER ═══
  console.log('\n📌 2. Auth — Register');
  {
    // Register User A (pemilik acara)
    const r = await request('POST', '/auth/register', {
      name: 'Pak Budi Santoso',
      email: 'budi@test.com',
      password: 'password123',
      phoneNumber: '081234567890',
      address: 'Jl. Merdeka No. 1, Yogyakarta',
    });
    assert('Register User A → 201', r.status === 201);
    assert('User A has token', !!r.data?.data?.token);
    tokenUserA = r.data?.data?.token;
    userA = r.data?.data?.user;
    assert('User A has id', !!userA?.id);
    assert('User A name correct', userA?.name === 'Pak Budi Santoso');
  }
  {
    // Register User B (calon tamu)
    const r = await request('POST', '/auth/register', {
      name: 'Ibu Sari Wulandari',
      email: 'sari@test.com',
      password: 'password123',
      phoneNumber: '081234567891',
      address: 'Jl. Kenanga No. 45, Semarang',
    });
    assert('Register User B → 201', r.status === 201);
    tokenUserB = r.data?.data?.token;
    userB = r.data?.data?.user;
    assert('User B has id', !!userB?.id);
  }
  {
    // Duplicate email
    const r = await request('POST', '/auth/register', {
      name: 'Duplicate',
      email: 'budi@test.com',
      password: 'password123',
    });
    assert('Duplicate email → 409', r.status === 409);
  }
  {
    // Missing fields
    const r = await request('POST', '/auth/register', {
      name: 'X',
    });
    assert('Missing required fields → 400', r.status === 400);
  }

  // ═══ 3. AUTH — LOGIN ═══
  console.log('\n📌 3. Auth — Login');
  {
    const r = await request('POST', '/auth/login', {
      email: 'budi@test.com',
      password: 'password123',
    });
    assert('Login User A → 200', r.status === 200);
    assert('Login returns token', !!r.data?.data?.token);
    tokenUserA = r.data?.data?.token; // refresh token
  }
  {
    const r = await request('POST', '/auth/login', {
      email: 'budi@test.com',
      password: 'wrongpassword',
    });
    assert('Wrong password → 401', r.status === 401);
  }
  {
    const r = await request('POST', '/auth/login', {
      email: 'nonexistent@test.com',
      password: 'password123',
    });
    assert('Non-existent email → 401', r.status === 401);
  }

  // ═══ 4. AUTH — GET ME ═══
  console.log('\n📌 4. Auth — Get Current User');
  {
    const r = await request('GET', '/auth/me', null, tokenUserA);
    assert('GET /auth/me → 200', r.status === 200);
    assert('Returns correct user', r.data?.data?.email === 'budi@test.com');
  }
  {
    const r = await request('GET', '/auth/me');
    assert('Without token → 401', r.status === 401);
  }
  {
    const r = await request('GET', '/auth/me', null, 'invalid.token.here');
    assert('Invalid token → 401', r.status === 401);
  }

  // ═══ 5. USERS ═══
  console.log('\n📌 5. Users — Profile');
  {
    const r = await request('GET', `/users/${userA.id}`);
    assert('GET /users/:id → 200', r.status === 200);
    assert('Returns user data', r.data?.data?.name === 'Pak Budi Santoso');
  }
  {
    const r = await request('PUT', '/users/profile', {
      name: 'Pak Budi S. (Updated)',
      address: 'Jl. Merdeka No. 1A, Yogyakarta',
    }, tokenUserA);
    assert('PUT /users/profile → 200', r.status === 200);
    assert('Name updated', r.data?.data?.name === 'Pak Budi S. (Updated)');
  }

  // ═══ 6. MASTER DATA ═══
  console.log('\n📌 6. Master Data — Categories');
  {
    const r = await request('GET', '/event-categories');
    assert('GET /event-categories → 200', r.status === 200);
    assert('Has 5 categories', r.data?.data?.length === 5);
    const names = r.data?.data?.map(c => c.name);
    assert('Has "Pernikahan"', names?.includes('Pernikahan'));
    assert('Has "Khitan"', names?.includes('Khitan'));
  }
  {
    const r = await request('GET', '/gift-categories');
    assert('GET /gift-categories → 200', r.status === 200);
    assert('Has 10 categories', r.data?.data?.length === 10);
    const names = r.data?.data?.map(c => c.name);
    assert('Has "Beras"', names?.includes('Beras'));
    assert('Has "Uang"', names?.includes('Uang'));
  }

  // ═══ 7. EVENTS — CREATE ═══
  console.log('\n📌 7. Events — Create');
  {
    const r = await request('POST', '/events', {
      eventCategoryId: 1,
      title: 'Pernikahan Anak Pak Budi',
      description: 'Resepsi pernikahan putra pertama Pak Budi',
      locationName: 'Gedung Serbaguna Yogyakarta',
      locationAddress: 'Jl. Solo Km 5, Yogyakarta',
      locationLat: -7.7956,
      locationLng: 110.3695,
      startDatetime: '2026-06-15T08:00:00.000Z',
      endDatetime: '2026-06-15T15:00:00.000Z',
      maxGuests: 50,
    }, tokenUserA);
    assert('Create event → 201', r.status === 201);
    assert('Event has id', !!r.data?.data?.id);
    assert('Status is draft', r.data?.data?.status === 'draft');
    assert('Title correct', r.data?.data?.title === 'Pernikahan Anak Pak Budi');
    eventId = r.data?.data?.id;
  }
  {
    // Without auth
    const r = await request('POST', '/events', {
      eventCategoryId: 1,
      title: 'Unauthorized',
      locationName: 'Test',
      locationAddress: 'Test Address',
      startDatetime: '2026-07-01T08:00:00.000Z',
      endDatetime: '2026-07-01T15:00:00.000Z',
    });
    assert('Create without auth → 401', r.status === 401);
  }

  // ═══ 8. EVENTS — BR-01 OVERLAP ═══
  console.log('\n📌 8. Events — BR-01 Schedule Overlap');
  {
    const r = await request('POST', '/events', {
      eventCategoryId: 2,
      title: 'Overlapping Event',
      locationName: 'Somewhere',
      locationAddress: 'Some Address',
      startDatetime: '2026-06-15T10:00:00.000Z',
      endDatetime: '2026-06-15T14:00:00.000Z',
    }, tokenUserA);
    assert('Overlapping schedule → 409', r.status === 409);
  }

  // ═══ 9. EVENTS — LIST & DETAIL ═══
  console.log('\n📌 9. Events — List & Detail');
  {
    // Still draft, so public list should be empty
    const r = await request('GET', '/events');
    assert('Public list (no published) → 200', r.status === 200);
    assert('No published events yet', r.data?.data?.length === 0);
  }
  {
    const r = await request('GET', '/events/my-events', null, tokenUserA);
    assert('My events → 200', r.status === 200);
    assert('Has 1 event', r.data?.data?.length === 1);
  }
  {
    const r = await request('GET', `/events/${eventId}`);
    assert('Event detail → 200', r.status === 200);
    assert('Has event category', !!r.data?.data?.eventCategory);
  }

  // ═══ 10. EVENTS — UPDATE ═══
  console.log('\n📌 10. Events — Update');
  {
    const r = await request('PUT', `/events/${eventId}`, {
      title: 'Pernikahan Anak Pak Budi (Updated)',
      maxGuests: 100,
    }, tokenUserA);
    assert('Update event → 200', r.status === 200);
    assert('Title updated', r.data?.data?.title === 'Pernikahan Anak Pak Budi (Updated)');
  }
  {
    // User B tries to update User A's event
    const r = await request('PUT', `/events/${eventId}`, {
      title: 'Hijacked',
    }, tokenUserB);
    assert('Non-owner update → 403', r.status === 403);
  }

  // ═══ 11. EVENTS — PUBLISH (Triggers Balas Budi) ═══
  console.log('\n📌 11. Events — Status Change (Publish)');
  {
    const r = await request('PATCH', `/events/${eventId}/status`, {
      status: 'published',
    }, tokenUserA);
    assert('Publish event → 200', r.status === 200);
    assert('Status is published', r.data?.data?.status === 'published');
  }
  {
    // Invalid transition: published → draft
    const r = await request('PATCH', `/events/${eventId}/status`, {
      status: 'draft',
    }, tokenUserA);
    assert('Invalid transition (published→draft) → 400', r.status === 400);
  }
  {
    // Now public list should have 1 event
    const r = await request('GET', '/events');
    assert('Public list has 1 event', r.data?.data?.length === 1);
  }

  // ═══ 12. EVENT GUESTS — APPLY (BR-02, BR-04) ═══
  console.log('\n📌 12. Event Guests — Apply');
  {
    // User B applies as guest with gifts
    const r = await request('POST', `/events/${eventId}/guests`, {
      notesFromGuest: 'Saya ingin hadir dan membawa bawaan.',
      gifts: [
        { giftCategoryId: 1, quantity: 5, notes: 'Beras premium' },
        { giftCategoryId: 4, quantity: 50000 },
      ],
    }, tokenUserB);
    assert('Apply as guest → 201', r.status === 201);
    assert('Has guest id', !!r.data?.data?.id);
    assert('Status is pending', r.data?.data?.applicationStatus === 'pending');
    assert('Has 2 gifts', r.data?.data?.guestGifts?.length === 2);
    guestId = r.data?.data?.id;
  }
  {
    // BR-02: User A can't apply to own event
    const r = await request('POST', `/events/${eventId}/guests`, {
      gifts: [{ giftCategoryId: 1, quantity: 3 }],
    }, tokenUserA);
    assert('BR-02: Apply to own event → 400', r.status === 400);
  }
  {
    // BR-03: User B can't apply twice (duplicate)
    const r = await request('POST', `/events/${eventId}/guests`, {
      gifts: [{ giftCategoryId: 2, quantity: 2 }],
    }, tokenUserB);
    assert('BR-03: Duplicate application → 409', r.status === 409);
  }
  {
    // BR-04: Apply without gifts
    // Register User C for this test
    const reg = await request('POST', '/auth/register', {
      name: 'User C',
      email: 'userc@test.com',
      password: 'password123',
    });
    const tokenC = reg.data?.data?.token;
    const r = await request('POST', `/events/${eventId}/guests`, {
      gifts: [],
    }, tokenC);
    assert('BR-04: Apply without gifts → 400', r.status === 400);
  }

  // ═══ 13. EVENT GUESTS — LIST (Owner Only) ═══
  console.log('\n📌 13. Event Guests — List (Owner Only)');
  {
    const r = await request('GET', `/events/${eventId}/guests`, null, tokenUserA);
    assert('List guests (owner) → 200', r.status === 200);
    assert('Has 1 guest', r.data?.data?.length === 1);
    assert('Guest has user info', !!r.data?.data?.[0]?.user);
    assert('Guest has gifts', r.data?.data?.[0]?.guestGifts?.length === 2);
  }
  {
    // Non-owner can't view guest list
    const r = await request('GET', `/events/${eventId}/guests`, null, tokenUserB);
    assert('BR-07: Non-owner list guests → 403', r.status === 403);
  }

  // ═══ 14. GUEST GIFTS — CRUD (BR-05) ═══
  console.log('\n📌 14. Guest Gifts — CRUD');
  {
    const r = await request('GET', `/guests/${guestId}/gifts`);
    assert('List gifts → 200', r.status === 200);
    assert('Has 2 gifts', r.data?.data?.length === 2);
  }
  let newGiftId;
  {
    const r = await request('POST', `/guests/${guestId}/gifts`, {
      giftCategoryId: 2,
      quantity: 3,
      notes: 'Gula pasir',
    }, tokenUserB);
    assert('Add gift → 201', r.status === 201);
    newGiftId = r.data?.data?.id;
  }
  {
    const r = await request('PUT', `/guests/${guestId}/gifts/${newGiftId}`, {
      quantity: 5,
    }, tokenUserB);
    assert('Update gift → 200', r.status === 200);
    assert('Quantity updated', r.data?.data?.quantity === 5);
  }
  {
    const r = await request('DELETE', `/guests/${guestId}/gifts/${newGiftId}`, null, tokenUserB);
    assert('Delete gift → 200', r.status === 200);
  }

  // ═══ 15. EVENT GUESTS — ACCEPT (BR-06, BR-07) ═══
  console.log('\n📌 15. Event Guests — Accept/Reject');
  {
    const r = await request('PATCH', `/events/${eventId}/guests/${guestId}/status`, {
      applicationStatus: 'accepted',
    }, tokenUserA);
    assert('Accept guest → 200', r.status === 200);
    assert('Status is accepted', r.data?.data?.applicationStatus === 'accepted');
  }
  {
    // BR-05: Can't edit gifts after acceptance
    const r = await request('POST', `/guests/${guestId}/gifts`, {
      giftCategoryId: 3,
      quantity: 2,
    }, tokenUserB);
    assert('BR-05: Edit gift after accepted → 400', r.status === 400);
  }

  // ═══ 16. EVENT GUESTS — ATTENDANCE (BR-07) ═══
  console.log('\n📌 16. Event Guests — Attendance Verification');
  {
    const r = await request('PATCH', `/events/${eventId}/guests/${guestId}/attendance`, {
      attendanceStatus: 'present',
    }, tokenUserA);
    assert('Verify attendance → 200', r.status === 200);
    assert('Attendance is present', r.data?.data?.attendanceStatus === 'present');
  }
  {
    // Non-owner can't verify
    const r = await request('PATCH', `/events/${eventId}/guests/${guestId}/attendance`, {
      attendanceStatus: 'present',
    }, tokenUserB);
    assert('BR-07: Non-owner verify → 403', r.status === 403);
  }

  // ═══ 17. EVENT GUESTS — VERIFY GIFT ═══
  console.log('\n📌 17. Event Guests — Gift Verification');
  {
    const r = await request('PATCH', `/events/${eventId}/guests/${guestId}/verify-gift`, null, tokenUserA);
    assert('Verify gift → 200', r.status === 200);
    assert('Gift verified', r.data?.data?.giftVerified === true);
  }

  // ═══ 18. NOTIFICATIONS ═══
  console.log('\n📌 18. Notifications');
  {
    // User A should have notification (new_applicant)
    const r = await request('GET', '/notifications', null, tokenUserA);
    assert('List notifications (User A) → 200', r.status === 200);
    assert('User A has notifications', r.data?.data?.notifications?.length > 0);
    assert('Has unread count', r.data?.data?.unreadCount >= 0);
  }
  {
    // User B should have notifications (accepted + attendance_verified)
    const r = await request('GET', '/notifications', null, tokenUserB);
    assert('List notifications (User B) → 200', r.status === 200);
    const notifs = r.data?.data?.notifications;
    assert('User B has notifications', notifs?.length > 0);
    const types = notifs?.map(n => n.type);
    assert('Has application_accepted notif', types?.includes('application_accepted'));
    assert('Has attendance_verified notif', types?.includes('attendance_verified'));

    // Mark one as read
    if (notifs?.length > 0) {
      const notifId = notifs[0].id;
      const r2 = await request('PATCH', `/notifications/${notifId}/read`, null, tokenUserB);
      assert('Mark as read → 200', r2.status === 200);
      assert('isRead is true', r2.data?.data?.isRead === true);
    }
  }
  {
    // Mark all as read
    const r = await request('PATCH', '/notifications/read-all', null, tokenUserB);
    assert('Mark all as read → 200', r.status === 200);
  }

  // ═══ 19. BALAS BUDI TRIGGER TEST ═══
  console.log('\n📌 19. Balas Budi Trigger');
  {
    // User B creates and publishes a new event
    // Since User A's event had User B as an attendee (present),
    // BUT balas budi is triggered when event OWNER publishes.
    // User B was guest, so we need to test the other direction:
    // User B publishes → users who attended B's events get notified.
    // Since B has no past events, let's test by creating event from B
    const r = await request('POST', '/events', {
      eventCategoryId: 3,
      title: 'Syukuran Ibu Sari',
      locationName: 'Rumah Ibu Sari',
      locationAddress: 'Jl. Kenanga No. 45, Semarang',
      startDatetime: '2026-07-20T09:00:00.000Z',
      endDatetime: '2026-07-20T14:00:00.000Z',
    }, tokenUserB);
    assert('User B creates event → 201', r.status === 201);
    const bEventId = r.data?.data?.id;

    const r2 = await request('PATCH', `/events/${bEventId}/status`, {
      status: 'published',
    }, tokenUserB);
    assert('User B publishes event → 200', r2.status === 200);

    // Since User A attended User B's past event? No, User B attended A's event.
    // So when A publishes again, B should get balas budi.
    // Let's create another event from A and publish
    const r3 = await request('POST', '/events', {
      eventCategoryId: 4,
      title: 'Aqiqah Cucu Pak Budi',
      locationName: 'Pendopo Budi',
      locationAddress: 'Jl. Merdeka No. 1, Yogyakarta',
      startDatetime: '2026-08-01T08:00:00.000Z',
      endDatetime: '2026-08-01T15:00:00.000Z',
    }, tokenUserA);
    assert('User A creates 2nd event → 201', r3.status === 201);
    const aEventId2 = r3.data?.data?.id;

    const r4 = await request('PATCH', `/events/${aEventId2}/status`, {
      status: 'published',
    }, tokenUserA);
    assert('User A publishes 2nd event → 200', r4.status === 200);

    // Now check User B's notifications for balas_budi
    const r5 = await request('GET', '/notifications?isRead=false', null, tokenUserB);
    const balasBudiNotifs = r5.data?.data?.notifications?.filter(n => n.type === 'balas_budi');
    assert('User B received balas_budi notification', balasBudiNotifs?.length > 0);
    if (balasBudiNotifs?.length > 0) {
      assert('Balas budi mentions event', balasBudiNotifs[0].message?.includes('Aqiqah'));
    }
  }

  // ═══ 20. EVENTS — DELETE (Only Draft) ═══
  console.log('\n📌 20. Events — Delete');
  {
    // Can't delete published event
    const r = await request('DELETE', `/events/${eventId}`, null, tokenUserA);
    assert('Delete published event → 400', r.status === 400);
  }
  {
    // Create a draft and delete it
    const create = await request('POST', '/events', {
      eventCategoryId: 5,
      title: 'Event Untuk Dihapus',
      locationName: 'Test',
      locationAddress: 'Test Address Here',
      startDatetime: '2026-12-01T08:00:00.000Z',
      endDatetime: '2026-12-01T15:00:00.000Z',
    }, tokenUserA);
    const tempId = create.data?.data?.id;

    const r = await request('DELETE', `/events/${tempId}`, null, tokenUserA);
    assert('Delete draft event → 200', r.status === 200);

    // Verify deleted
    const r2 = await request('GET', `/events/${tempId}`);
    assert('Deleted event not found → 404', r2.status === 404);
  }

  // ═══ 21. 404 HANDLER ═══
  console.log('\n📌 21. Error Handling');
  {
    const r = await request('GET', '/nonexistent/endpoint');
    assert('Unknown endpoint → 404', r.status === 404);
  }
  {
    const r = await request('GET', '/events/999999');
    assert('Non-existent event → 404', r.status === 404);
  }

  // ═══ SUMMARY ═══
  console.log('\n══════════════════════════════════════════');
  console.log(`  📊 RESULTS: ${passed} passed, ${failed} failed, ${passed + failed} total`);
  console.log('══════════════════════════════════════════\n');

  if (failed > 0) {
    process.exit(1);
  }
}

runTests().catch((err) => {
  console.error('💥 Test runner error:', err);
  process.exit(1);
});
