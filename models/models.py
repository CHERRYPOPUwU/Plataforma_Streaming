from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from datetime import datetime

db = SQLAlchemy()

class Account(UserMixin, db.Model):
    __tablename__ = 'accounts'
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(255), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    last_login = db.Column(db.DateTime)
    locale = db.Column(db.String(10))
    role = db.Column(db.String(50), default='user')

    profiles = db.relationship('Profile', backref='account', cascade='all, delete-orphan')
    subscriptions = db.relationship('Subscription', backref='account', cascade='all, delete-orphan')
    payments = db.relationship('Payment', backref='account', cascade='all, delete-orphan')

class Profile(db.Model):
    __tablename__ = 'profiles'
    id = db.Column(db.Integer, primary_key=True)
    account_id = db.Column(db.Integer, db.ForeignKey('accounts.id', ondelete='CASCADE'))
    name = db.Column(db.String(100), nullable=False)
    avatar_url = db.Column(db.Text)
    birthdate = db.Column(db.Date)
    is_kids = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    watchlists = db.relationship('Watchlist', backref='profile', cascade='all, delete-orphan')
    watch_history = db.relationship('WatchHistory', backref='profile', cascade='all, delete-orphan')
    ratings = db.relationship('Rating', backref='profile', cascade='all, delete-orphan')
    recommendations = db.relationship('Recommendation', backref='profile', cascade='all, delete-orphan')
    parental_control = db.relationship('ParentalControl', uselist=False, backref='profile', cascade='all, delete-orphan')

class ParentalControl(db.Model):
    __tablename__ = 'parental_controls'
    id = db.Column(db.Integer, primary_key=True)
    profile_id = db.Column(db.Integer, db.ForeignKey('profiles.id', ondelete='CASCADE'))
    max_rating = db.Column(db.String(10))
    blocked_genre_ids = db.Column(db.ARRAY(db.Integer))
    blocked_content = db.Column(db.ARRAY(db.Integer))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Plan(db.Model):
    __tablename__ = 'plans'
    id = db.Column(db.Integer, primary_key=True)
    code = db.Column(db.String(50), unique=True, nullable=False)
    name = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text)
    price_cents = db.Column(db.Integer, nullable=False)
    currency = db.Column(db.String(10), default='USD')
    max_streams = db.Column(db.Integer, default=1)
    resolution_limit = db.Column(db.String(20))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    active = db.Column(db.Boolean, default=True)

class Subscription(db.Model):
    __tablename__ = 'subscriptions'
    id = db.Column(db.Integer, primary_key=True)
    account_id = db.Column(db.Integer, db.ForeignKey('accounts.id', ondelete='CASCADE'))
    plan_id = db.Column(db.Integer, db.ForeignKey('plans.id'))
    status = db.Column(db.String(50), default='active')
    started_at = db.Column(db.DateTime, default=datetime.utcnow)
    current_period_start = db.Column(db.DateTime)
    current_period_end = db.Column(db.DateTime)
    cancel_at_period_end = db.Column(db.Boolean, default=False)
    canceled_at = db.Column(db.DateTime)

    plan = db.relationship('Plan')

class Payment(db.Model):
    __tablename__ = 'payments'
    id = db.Column(db.Integer, primary_key=True)
    account_id = db.Column(db.Integer, db.ForeignKey('accounts.id', ondelete='CASCADE'))
    subscription_id = db.Column(db.Integer, db.ForeignKey('subscriptions.id', ondelete='SET NULL'))
    amount_cents = db.Column(db.Integer, nullable=False)
    currency = db.Column(db.String(10), default='USD')
    status = db.Column(db.String(50), default='pending')
    paid_at = db.Column(db.DateTime)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Content(db.Model):
    __tablename__ = 'contents'
    id = db.Column(db.Integer, primary_key=True)
    type = db.Column(db.String(50))
    title = db.Column(db.String(255), nullable=False)
    original_title = db.Column(db.String(255))
    synopsis = db.Column(db.Text)
    release_date = db.Column(db.Date)
    runtime_minutes = db.Column(db.Integer)
    year = db.Column(db.Integer)
    rating_avg = db.Column(db.Numeric(3,2), default=0)
    rating_count = db.Column(db.Integer, default=0)
    language_primary = db.Column(db.String(10))
    maturity_rating = db.Column(db.String(10))
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow)

    series = db.relationship('Series', uselist=False, backref='content', cascade='all, delete-orphan')
    episodes = db.relationship('Episode', backref='content', cascade='all, delete-orphan')
    genres = db.relationship('Genre', secondary='content_genres', backref='contents')

class Series(db.Model):
    __tablename__ = 'series'
    id = db.Column(db.Integer, db.ForeignKey('contents.id', ondelete='CASCADE'), primary_key=True)
    total_seasons = db.Column(db.Integer, default=0)
    total_episodes = db.Column(db.Integer, default=0)
    showrunner = db.Column(db.String(255))

class Season(db.Model):
    __tablename__ = 'seasons'
    id = db.Column(db.Integer, primary_key=True)
    series_id = db.Column(db.Integer, db.ForeignKey('series.id', ondelete='CASCADE'))
    season_number = db.Column(db.Integer, nullable=False)
    title = db.Column(db.String(255))
    overview = db.Column(db.Text)
    release_date = db.Column(db.Date)

    episodes = db.relationship('Episode', backref='season', cascade='all, delete-orphan')

class Episode(db.Model):
    __tablename__ = 'episodes'
    id = db.Column(db.Integer, primary_key=True)
    content_id = db.Column(db.Integer, db.ForeignKey('contents.id', ondelete='CASCADE'))
    season_id = db.Column(db.Integer, db.ForeignKey('seasons.id', ondelete='CASCADE'))
    episode_number = db.Column(db.Integer, nullable=False)
    title = db.Column(db.String(255))
    synopsis = db.Column(db.Text)
    runtime_minutes = db.Column(db.Integer)
    released_at = db.Column(db.Date)

class Genre(db.Model):
    __tablename__ = 'genres'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), unique=True, nullable=False)
    slug = db.Column(db.String(100), unique=True, nullable=False)

class ContentGenre(db.Model):
    __tablename__ = 'content_genres'
    content_id = db.Column(db.Integer, db.ForeignKey('contents.id', ondelete='CASCADE'), primary_key=True)
    genre_id = db.Column(db.Integer, db.ForeignKey('genres.id', ondelete='CASCADE'), primary_key=True)

class Actor(db.Model):
    __tablename__ = 'actor'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    birthdate = db.Column(db.Date)
    bio = db.Column(db.Text)

class Watchlist(db.Model):
    __tablename__ = 'watchlists'
    id = db.Column(db.Integer, primary_key=True)
    profile_id = db.Column(db.Integer, db.ForeignKey('profiles.id', ondelete='CASCADE'))
    content_id = db.Column(db.Integer, db.ForeignKey('contents.id', ondelete='CASCADE'))
    added_at = db.Column(db.DateTime, default=datetime.utcnow)

class WatchHistory(db.Model):
    __tablename__ = 'watch_history'
    id = db.Column(db.Integer, primary_key=True)
    profile_id = db.Column(db.Integer, db.ForeignKey('profiles.id', ondelete='CASCADE'))
    content_id = db.Column(db.Integer, db.ForeignKey('contents.id', ondelete='CASCADE'))
    episode_id = db.Column(db.Integer, db.ForeignKey('episodes.id', ondelete='SET NULL'))
    started_at = db.Column(db.DateTime, default=datetime.utcnow)
    last_position_seconds = db.Column(db.Integer, default=0)
    finished = db.Column(db.Boolean, default=False)
    finished_at = db.Column(db.DateTime)

class Rating(db.Model):
    __tablename__ = 'ratings'
    id = db.Column(db.Integer, primary_key=True)
    profile_id = db.Column(db.Integer, db.ForeignKey('profiles.id', ondelete='CASCADE'))
    content_id = db.Column(db.Integer, db.ForeignKey('contents.id', ondelete='CASCADE'))
    score = db.Column(db.Integer)
    review_text = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Recommendation(db.Model):
    __tablename__ = 'recommendations'
    id = db.Column(db.Integer, primary_key=True)
    profile_id = db.Column(db.Integer, db.ForeignKey('profiles.id', ondelete='CASCADE'))
    content_id = db.Column(db.Integer, db.ForeignKey('contents.id', ondelete='CASCADE'))
    reason = db.Column(db.Text)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
