import pandas as pd
from datetime import datetime

TECHNICAL_DEFAULT_DATE = '1900-01-01'
TECHNICAL_DEFAULT_DATETIME = '1900-01-01 00:00:00'

DATE_FORMATS = [
    '%Y-%m-%d',
    '%Y/%m/%d',
    '%d-%m-%Y',
    '%d/%m/%Y',
    '%m-%d-%Y',
    '%m/%d/%Y',
    '%Y%m%d',
    '%d.%m.%Y',
    '%Y.%m.%d',
    '%b %d, %Y',
    '%d %b %Y',
    '%B %d, %Y',
    '%d %B %Y',
]

DATETIME_FORMATS = [
    '%Y-%m-%d %H:%M:%S',
    '%Y/%m/%d %H:%M:%S',
    '%Y-%m-%d %H:%M',
    '%Y/%m/%d %H:%M',
    '%Y-%m-%d',
    '%Y/%m/%d',
    '%d-%m-%Y %H:%M:%S',
    '%d/%m/%Y %H:%M:%S',
    '%d-%m-%Y',
    '%d/%m/%Y',
]


def _is_empty(value):
    return value is None or pd.isna(value) or str(value).strip() == ''


def _is_valid_date(parsed_date):
    if parsed_date.year < 1900 or parsed_date.year > 2100:
        return False
    if parsed_date > datetime.now():
        return False
    return True


def validate_and_fix_date(date_value):
    """
    Validates a date and returns it in YYYY-MM-DD format.
    Invalid dates are replaced with the technical default 1900-01-01.
    """
    if _is_empty(date_value):
        return TECHNICAL_DEFAULT_DATE

    date_str = str(date_value).strip()

    for fmt in DATE_FORMATS:
        try:
            parsed_date = datetime.strptime(date_str, fmt)
            if not _is_valid_date(parsed_date):
                return TECHNICAL_DEFAULT_DATE
            return parsed_date.strftime('%Y-%m-%d')
        except ValueError:
            continue

    return TECHNICAL_DEFAULT_DATE


def fix_sales_timestamp(sales_timestamp):
    """
    Fixes sales timestamp values.
    Returns None when the row should be removed because the date is missing.
    Adds 00:00:00 when only a date is present.
    """
    if _is_empty(sales_timestamp):
        return None

    date_str = str(sales_timestamp).strip()

    for fmt in DATETIME_FORMATS:
        try:
            parsed_datetime = datetime.strptime(date_str, fmt)
            if not _is_valid_date(parsed_datetime):
                return None
            if fmt in ('%Y-%m-%d', '%Y/%m/%d', '%d-%m-%Y', '%d/%m/%Y'):
                return parsed_datetime.strftime('%Y-%m-%d 00:00:00')
            if fmt in ('%Y-%m-%d %H:%M', '%Y/%m/%d %H:%M'):
                return parsed_datetime.strftime('%Y-%m-%d %H:%M:00')
            return parsed_datetime.strftime('%Y-%m-%d %H:%M:%S')
        except ValueError:
            continue

    return None


def fix_datetime(datetime_value):
    """
    Fixes timestamp values for non-sales tables.
    Falls back to the technical default when parsing fails.
    """
    if _is_empty(datetime_value):
        return TECHNICAL_DEFAULT_DATETIME

    date_str = str(datetime_value).strip()

    for fmt in DATETIME_FORMATS:
        try:
            parsed_datetime = datetime.strptime(date_str, fmt)
            if not _is_valid_date(parsed_datetime):
                return TECHNICAL_DEFAULT_DATETIME
            if fmt in ('%Y-%m-%d', '%Y/%m/%d', '%d-%m-%Y', '%d/%m/%Y'):
                return parsed_datetime.strftime('%Y-%m-%d 00:00:00')
            if fmt in ('%Y-%m-%d %H:%M', '%Y/%m/%d %H:%M'):
                return parsed_datetime.strftime('%Y-%m-%d %H:%M:00')
            return parsed_datetime.strftime('%Y-%m-%d %H:%M:%S')
        except ValueError:
            continue

    return TECHNICAL_DEFAULT_DATETIME


def convert_yes_no_to_bool(value):
    mapping = {'Yes': True, 'No': False}
    return mapping.get(str(value).strip(), False)
