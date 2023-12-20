import time
from sqlalchemy import create_engine, MetaData, Table, Column, String
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from contextlib import contextmanager
import os

DATABASE_URL = os.environ['DATABASE_URL']

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

print("Connecting to database...")


Base = declarative_base()

# Modèle pour la table 'clients'
class Client(Base):
    __tablename__ = 'clients'
    domain = Column(String, primary_key=True, index=True)

# Database initialization flag
db_initialized = False

# Initialisation de la base de données
def init_db(retry_count=5, delay=5):
    global db_initialized
    if not db_initialized:
        attempts = 0
        while attempts < retry_count:
            try:
                Base.metadata.create_all(bind=engine)
                db_initialized = True
                print("Database initialized.")
                break
            except Exception as e:
                print(f"Error initializing the database: {e}")
                attempts += 1
                print(f"Attempt {attempts} failed. Retrying in {delay} seconds.")
                time.sleep(delay)
        if attempts == retry_count:
            print("Failed to initialize the database after multiple attempts.")

def init_client_data():
    with session_scope() as session:
        # Vérifiez si l'URL du client existe déjà
        client_url = "polytech.univ-cotedazur.fr"
        existing_client = session.query(Client).filter(Client.domain == client_url).first()

        if not existing_client:
            # Ajoutez le client s'il n'existe pas
            new_client = Client(domain=client_url)
            session.add(new_client)


# Context manager pour la session
@contextmanager
def session_scope():
    session = SessionLocal()
    try:
        yield session
        session.commit()
    except:
        session.rollback()
        raise
    finally:
        session.close()
