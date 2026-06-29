// P4 wire-up — O10 ScheduledJobCatalog runtime registry.
//
// Each catalog entry (lib/services/ops/scheduled_job_catalog.dart)
// becomes a Cloud Function exported below, scheduled via
// functions.pubsub.schedule(cron) with the cron expression derived
// from the catalog's cadenceLabel. Handlers are idempotent stubs
// that increment a counter + log the run — real business logic
// ships in dedicated follow-up PRs per job family.
//
// Source of truth = the Dart catalog. Drift detector test on the
// Dart side enforces (a) every catalog entry has a registry entry
// here, and (b) the cron expression matches what
// cadenceLabelToCron produces for the catalog's cadenceLabel.

const DAY_OF_WEEK: Record<string, number> = {
  sunday: 0,
  monday: 1,
  tuesday: 2,
  wednesday: 3,
  thursday: 4,
  friday: 5,
  saturday: 6,
};

// Convert the catalog's grep-able cadence label to a standard cron
// expression (UTC, 5-field format).
//
// Supported patterns:
//   nightly-<hhmm>-utc
//   daily-<hhmm>-utc
//   weekly-<dow>-<hhmm>-utc        (dow = sunday..saturday)
//   monthly-<dom>-<hhmm>-utc       (dom = 1..31, "1st"/"2nd"/... ok)
//   every-N-min
//   every-N-days-<hhmm>-utc
export function cadenceLabelToCron(label: string): string {
  // every-N-min
  let m = /^every-(\d+)-min$/.exec(label);
  if (m) {
    return `*/${m[1]} * * * *`;
  }

  // every-N-days-hhmm-utc
  m = /^every-(\d+)-days-(\d{2})(\d{2})-utc$/.exec(label);
  if (m) {
    const [, n, hh, mm] = m;
    return `${parseInt(mm, 10)} ${parseInt(hh, 10)} */${n} * *`;
  }

  // nightly-hhmm-utc or daily-hhmm-utc
  m = /^(nightly|daily)-(\d{2})(\d{2})-utc$/.exec(label);
  if (m) {
    const [, , hh, mm] = m;
    return `${parseInt(mm, 10)} ${parseInt(hh, 10)} * * *`;
  }

  // weekly-<dow>-hhmm-utc
  m = /^weekly-([a-z]+)-(\d{2})(\d{2})-utc$/.exec(label);
  if (m) {
    const [, dowName, hh, mm] = m;
    const dow = DAY_OF_WEEK[dowName];
    if (dow === undefined) {
      throw new Error(`unknown day-of-week "${dowName}" in "${label}"`);
    }
    return `${parseInt(mm, 10)} ${parseInt(hh, 10)} * * ${dow}`;
  }

  // monthly-<dom>-hhmm-utc (1st, 2nd, ...)
  m = /^monthly-(\d+)(?:st|nd|rd|th)?-(\d{2})(\d{2})-utc$/.exec(label);
  if (m) {
    const [, dom, hh, mm] = m;
    return `${parseInt(mm, 10)} ${parseInt(hh, 10)} ${parseInt(dom, 10)} * *`;
  }

  throw new Error(`unsupported cadence label "${label}"`);
}

export interface JobMetric {
  jobId: string;
  ranAtMs: number;
  outcome: 'ok' | 'noop' | 'error';
  detail?: string;
}

/**
 * In-process metric collector. Production wiring routes these to
 * Sentry / Cloud Monitoring in a follow-up PR.
 */
export const _jobMetricsForTest: JobMetric[] = [];

export function recordJobRun(metric: JobMetric): void {
  _jobMetricsForTest.push(metric);
}

export function resetMetricsForTest(): void {
  _jobMetricsForTest.length = 0;
}

/**
 * Idempotent stub handler. Returns the metric so callers / tests
 * can inspect what was recorded.
 */
async function stubHandler(jobId: string): Promise<JobMetric> {
  const metric: JobMetric = {
    jobId,
    ranAtMs: Date.now(),
    outcome: 'noop',
    detail: 'stub: real implementation ships in follow-up PR per job family',
  };
  recordJobRun(metric);
  return metric;
}

/**
 * Job registry mirrored from the Dart catalog. Every catalog id
 * MUST appear here; drift detector enforces.
 */
export const SCHEDULED_JOBS: ReadonlyArray<{
  id: string;
  cadenceLabel: string;
  cron: string;
  handler: () => Promise<JobMetric>;
}> = [
  {
    id: 'nightly-backup',
    cadenceLabel: 'nightly-0200-utc',
    cron: cadenceLabelToCron('nightly-0200-utc'),
    handler: () => stubHandler('nightly-backup'),
  },
  {
    id: 'jwt-signing-key-rotation',
    cadenceLabel: 'every-90-days-0300-utc',
    cron: cadenceLabelToCron('every-90-days-0300-utc'),
    handler: () => stubHandler('jwt-signing-key-rotation'),
  },
  {
    id: 'audit-log-hmac-rotation',
    cadenceLabel: 'every-180-days-0300-utc',
    cron: cadenceLabelToCron('every-180-days-0300-utc'),
    handler: () => stubHandler('audit-log-hmac-rotation'),
  },
  {
    id: 'retention-purge-clinical-record',
    cadenceLabel: 'monthly-1st-0400-utc',
    cron: cadenceLabelToCron('monthly-1st-0400-utc'),
    handler: () => stubHandler('retention-purge-clinical-record'),
  },
  {
    id: 'product-analytics-anonymise',
    cadenceLabel: 'weekly-sunday-0400-utc',
    cron: cadenceLabelToCron('weekly-sunday-0400-utc'),
    handler: () => stubHandler('product-analytics-anonymise'),
  },
  {
    id: 'cssrs-positive-followup-sweep',
    cadenceLabel: 'every-15-min',
    cron: cadenceLabelToCron('every-15-min'),
    handler: () => stubHandler('cssrs-positive-followup-sweep'),
  },
  {
    id: 'dsar-deadline-sweep',
    cadenceLabel: 'daily-0900-utc',
    cron: cadenceLabelToCron('daily-0900-utc'),
    handler: () => stubHandler('dsar-deadline-sweep'),
  },
  {
    id: 'auth-event-purge',
    cadenceLabel: 'monthly-1st-0500-utc',
    cron: cadenceLabelToCron('monthly-1st-0500-utc'),
    handler: () => stubHandler('auth-event-purge'),
  },
];

export function getJobById(id: string) {
  return SCHEDULED_JOBS.find((j) => j.id === id);
}
