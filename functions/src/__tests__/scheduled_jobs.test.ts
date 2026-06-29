import {
  cadenceLabelToCron,
  SCHEDULED_JOBS,
  getJobById,
  resetMetricsForTest,
  _jobMetricsForTest,
} from '../scheduled/scheduled_jobs';

describe('scheduled_jobs registry', () => {
  beforeEach(() => {
    resetMetricsForTest();
  });

  test('registry has exactly 8 jobs (mirrors O10 catalog scope)', () => {
    expect(SCHEDULED_JOBS).toHaveLength(8);
  });

  test('every job id is unique', () => {
    const ids = SCHEDULED_JOBS.map((j) => j.id);
    expect(new Set(ids).size).toBe(ids.length);
  });

  test('every job id is kebab-case', () => {
    const pattern = /^[a-z][a-z0-9-]*$/;
    for (const j of SCHEDULED_JOBS) {
      expect(pattern.test(j.id)).toBe(true);
    }
  });

  test('getJobById resolves every job + returns undefined for unknown', () => {
    for (const j of SCHEDULED_JOBS) {
      expect(getJobById(j.id)).toBe(j);
    }
    expect(getJobById('does-not-exist')).toBeUndefined();
  });

  test('every handler is idempotent (multiple runs do not throw)', async () => {
    for (const j of SCHEDULED_JOBS) {
      const m1 = await j.handler();
      const m2 = await j.handler();
      expect(m1.jobId).toBe(j.id);
      expect(m2.jobId).toBe(j.id);
      expect(m1.outcome).toBe('noop');
    }
    expect(_jobMetricsForTest).toHaveLength(SCHEDULED_JOBS.length * 2);
  });

  test('every cron is 5 fields', () => {
    for (const j of SCHEDULED_JOBS) {
      const parts = j.cron.split(/\s+/);
      expect(parts).toHaveLength(5);
    }
  });
});

describe('cadenceLabelToCron', () => {
  test.each([
    ['nightly-0200-utc', '0 2 * * *'],
    ['daily-0900-utc', '0 9 * * *'],
    ['every-15-min', '*/15 * * * *'],
    ['every-90-days-0300-utc', '0 3 */90 * *'],
    ['every-180-days-0300-utc', '0 3 */180 * *'],
    ['weekly-sunday-0400-utc', '0 4 * * 0'],
    ['monthly-1st-0400-utc', '0 4 1 * *'],
    ['monthly-1st-0500-utc', '0 5 1 * *'],
  ])('converts %s → %s', (label, cron) => {
    expect(cadenceLabelToCron(label)).toBe(cron);
  });

  test('throws on unsupported label', () => {
    expect(() => cadenceLabelToCron('bogus-label')).toThrow();
  });

  test('throws on unknown day-of-week', () => {
    expect(() =>
      cadenceLabelToCron('weekly-someday-0400-utc'),
    ).toThrow();
  });
});

describe('scheduled job catalog regulatory pins', () => {
  test('cssrs-positive-followup-sweep runs every 15 minutes (clinical safety)', () => {
    const j = getJobById('cssrs-positive-followup-sweep');
    expect(j).toBeDefined();
    expect(j!.cron).toBe('*/15 * * * *');
  });

  test('nightly-backup at 0200 UTC (RPO floor)', () => {
    const j = getJobById('nightly-backup');
    expect(j).toBeDefined();
    expect(j!.cron).toBe('0 2 * * *');
  });

  test('jwt-signing-key-rotation every 90 days (N20)', () => {
    const j = getJobById('jwt-signing-key-rotation');
    expect(j!.cron).toBe('0 3 */90 * *');
  });

  test('audit-log-hmac-rotation every 180 days (N20)', () => {
    const j = getJobById('audit-log-hmac-rotation');
    expect(j!.cron).toBe('0 3 */180 * *');
  });
});
