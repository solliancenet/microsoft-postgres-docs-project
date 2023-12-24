create database airbnb;

CREATE TABLE temp_calendar (data jsonb);
CREATE TABLE temp_listings (data jsonb);
CREATE TABLE temp_reviews (data jsonb);

\COPY temp_calendar (data) FROM 'C:\microsoft-postgres-docs-project\artifacts\data\calendar.json';
\COPY temp_listings (data) FROM 'C:\microsoft-postgres-docs-project\artifacts\data\listings.json';
\COPY temp_reviews (data) FROM 'C:\microsoft-postgres-docs-project\artifacts\data\reviews.json';

CREATE TABLE listings (listing_id varchar(50), data jsonb);
CREATE TABLE reviews (listing_id varchar(50), data jsonb);
CREATE TABLE calendar (listing_id varchar(50), data jsonb);

INSERT INTO listings
SELECT replace(data['id']::varchar(50), '"', ''), data::jsonb
FROM temp_listings;

INSERT INTO reviews
SELECT replace(data['listing_id']::varchar(50), '"', ''), data::jsonb
FROM temp_reviews;

INSERT INTO calendar
SELECT replace(data['listing_id']::varchar(50), '"', ''), data::jsonb
FROM temp_calendar;