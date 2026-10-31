return {
	["AccountNumber"] = XXXX, -- Replace this with your actual acc number from RCS!
	["ReportingURL"] = "https://rcs.pyramus.dev/api/v2/reporting",
	["ReportAttempts"] = 4, -- Number of send attempts before declaring Comm Fail, mirrors real dialer retry counts.
	["RetryDelay"] = 2, -- Seconds between retry attempts.
}
