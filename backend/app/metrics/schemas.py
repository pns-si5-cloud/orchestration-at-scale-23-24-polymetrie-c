import pydantic

class Tracker(pydantic.BaseModel):
    WINDOW_LOCATION_HREF: str
    USER_AGENT: str
    PLATFORM: str
    TIMEZONE: str

class Metric(pydantic.BaseModel):
    tracker: Tracker