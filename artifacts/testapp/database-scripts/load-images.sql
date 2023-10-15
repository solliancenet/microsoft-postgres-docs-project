-- Copy speaker-bio-pic1.png to PostgreSQL Data Directory

UPDATE reg_app.speakers
SET speaker_pic = pg_read_binary_file('speaker-bio-pic1.png');

-- Copy event-pic0.jpg to PostgreSQL Data Directory

UPDATE reg_app.events
SET event_pic = pg_read_binary_file('event-pic0.jpg');