CREATE SCHEMA IF NOT EXISTS REG_APP;

DROP TABLE IF EXISTS REG_APP.REGISTRATIONS CASCADE;
DROP TABLE IF EXISTS REG_APP.SESSIONS CASCADE;
DROP TABLE IF EXISTS REG_APP.ATTENDEES CASCADE;
DROP TABLE IF EXISTS REG_APP.ATTENDEES_AUDIT CASCADE;
DROP TABLE IF EXISTS REG_APP.EVENTS CASCADE;
DROP TABLE IF EXISTS REG_APP.SPEAKERS CASCADE;
DROP TABLE IF EXISTS REG_APP.JOBS CASCADE;
DROP TABLE IF EXISTS REG_APP.ddl_history CASCADE;
DROP VIEW IF EXISTS REG_APP.V_ATTENDEE_SESSIONS CASCADE;
DROP VIEW IF EXISTS REG_APP.V_SPK_SESSION CASCADE;

--DROP COLLATION IF EXISTS "C" CASCADE;

DROP FUNCTION IF EXISTS REG_APP.GET_RANDOM_ATTENDEE CASCADE;
DROP FUNCTION IF EXISTS REG_APP.REGISTER_ATTENDEE_SESSION CASCADE;
DROP FUNCTION IF EXISTS REG_APP.Hello_world CASCADE;

DROP TEXT SEARCH CONFIGURATION IF EXISTS reg_app."FTS_Main";
DROP TEXT SEARCH DICTIONARY IF EXISTS reg_app."FTS_Main_Dict";
DROP TEXT SEARCH PARSER IF EXISTS reg_app."FTS_Main_Parser";
DROP TEXT SEARCH TEMPLATE IF EXISTS reg_app."FTS_Main_Template";

DROP TYPE IF EXISTS Address;
DROP TYPE IF EXISTS Color;

DROP SEQUENCE IF EXISTS mysequence;

DROP FUNCTION IF EXISTS perl_max;

CREATE TABLE Reg_App.ddl_history (
  id serial primary key,
  ddl_date timestamptz,
  ddl_tag text,
  object_name text
);

--  DDL for Table ATTENDEES

CREATE TABLE REG_APP.ATTENDEES
(	ID INT, 
FIRST_NAME VARCHAR(50), 
LAST_NAME VARCHAR(50), 
EMAIL_ADDRESS VARCHAR(200)
);

CREATE TABLE REG_APP.Attendees_Audit
(
Id INT NOT NULL,
LastName VARCHAR(20) NOT NULL,
FirstName VARCHAR(20) NOT NULL,
EmailAddress VARCHAR(20) NOT NULL,
UserName VARCHAR(20) NOT NULL,
AuditTime VARCHAR(20) NOT NULL
);

--  DDL for Table EVENTS

  CREATE TABLE REG_APP.EVENTS
   (	ID INT, 
	EVENT_NAME VARCHAR(300), 
	EVENT_DESCRIPTION VARCHAR(2000), 
	EVENT_START_DATE TIMESTAMP, 
	EVENT_PRICE DECIMAL, 
	EVENT_END_DATE TIMESTAMP, 
	EVENT_PIC BYTEA
   );

--  DDL for Table REGISTRATIONS

  CREATE TABLE REG_APP.REGISTRATIONS
   (	ID INT , 
	REGISTRATION_DATE TIMESTAMP NOT NULL, 
	SESSION_ID INT NOT NULL, 
	ATTENDEE_ID INT NOT NULL
   );

--  DDL for Table SESSIONS

  CREATE TABLE REG_APP.SESSIONS
   (	ID INT, 
	NAME VARCHAR(300), 
	DESCRIPTION VARCHAR(2000), 
	SESSION_DATE TIMESTAMP, 
	SPEAKER_ID INT, 
	EVENT_ID INT, 
	DURATION DECIMAL
   ); 

--  DDL for Table SPEAKERS

  CREATE TABLE REG_APP.SPEAKERS
   (	ID INT, 
	FIRST_NAME VARCHAR(50), 
	LAST_NAME VARCHAR(50), 
	SPEAKER_PIC BYTEA, 
	SPEAKER_BIO TEXT
   );

  --  DDL for Table JOBS

  CREATE TABLE REG_APP.JOBS
   (	ID INT, 
	NAME VARCHAR(50), 
	LAST_RUN VARCHAR(50), 
	COUNT INT
   );

--  DDL for View V_ATTENDEE_SESSIONS-

  CREATE OR REPLACE VIEW REG_APP.V_ATTENDEE_SESSIONS (ATTENDEE_ID, FIRST_NAME, LAST_NAME, SESSION_NAME, SESSION_START, DURATION, REGISTRATION_DATE) 
  AS 
  SELECT
    att.ID as attendee_id,
    att.FIRST_NAME,
    att.LAST_NAME,
    ses.NAME as session_name,
    ses.SESSION_DATE as session_start,
    ses.DURATION,
    reg.REGISTRATION_DATE
FROM 
    REG_APP.ATTENDEES att 
        inner join REG_APP.REGISTRATIONS reg
            on att.ID = reg.ATTENDEE_ID
        inner join REG_APP.SESSIONS ses
            on ses.ID = reg.SESSION_ID
;

--  DDL for Materialized View MV_ATTENDEE_SESSIONS-
CREATE MATERIALIZED VIEW REG_APP.MV_ATTENDEE_SESSIONS (ATTENDEE_ID, FIRST_NAME, LAST_NAME, SESSION_NAME, SESSION_START, DURATION, REGISTRATION_DATE) 
  AS 
  SELECT
    att.ID as attendee_id,
    att.FIRST_NAME,
    att.LAST_NAME,
    ses.NAME as session_name,
    ses.SESSION_DATE as session_start,
    ses.DURATION,
    reg.REGISTRATION_DATE
FROM 
    REG_APP.ATTENDEES att 
        inner join REG_APP.REGISTRATIONS reg
            on att.ID = reg.ATTENDEE_ID
        inner join REG_APP.SESSIONS ses
            on ses.ID = reg.SESSION_ID
;

--  DDL for View V_SPK_SESSION

  CREATE OR REPLACE VIEW REG_APP.V_SPK_SESSION (SPEAKER_ID, FIRST_NAME, LAST_NAME, SESSION_ID, SESSION_NAME, SESSION_DESCRIPTION, SESSION_DATE, DURATION, EVENT_ID) AS 
  select 
    spk.id as speaker_id, 
    spk.first_name,
    spk.last_name, 
    ses.id as session_id, 
    ses.name as session_name, 
    ses.description as session_description, 
    ses.session_date, 
    ses.duration,
    ses.event_id
from REG_APP.SPEAKERS spk
    inner join REG_APP.SESSIONS ses
        on ses.speaker_id = spk.id
;

-- INSERTING into REG_APP.ATTENDEES
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (1,'Orlando','Gee','orlando0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (2,'Keith','Harris','keith0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (3,'Donna','Carreras','donna0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (4,'Janet','Gates','janet1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (5,'Lucy','Harrington','lucy0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (6,'Rosmarie','Carroll','rosmarie0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (7,'Dominic','Gash','dominic0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (10,'Kathleen','Garza','kathleen0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (11,'Katherine','Harding','katherine0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (12,'Johnny','Caprio','johnny0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (16,'Christopher','Beck','christopher1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (18,'David','Liu','david20@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (19,'John','Beaver','john8@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (20,'Jean','Handley','jean1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (21,'Jinghao','Liu','jinghao1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (22,'Linda','Burnett','linda4@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (23,'Kerim','Hanif','kerim0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (24,'Kevin','Liu','kevin5@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (25,'Donald','Blanton','donald0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (28,'Jackie','Blackwell','jackie0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (29,'Bryan','Hamilton','bryan2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (30,'Todd','Logan','todd0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (34,'Barbara','German','barbara4@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (37,'Jim','Geist','jim1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (38,'Betty','Haines','betty0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (39,'Sharon','Looney','sharon2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (40,'Darren','Gehring','darren0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (41,'Erin','Hagens','erin1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (42,'Jeremy','Los','jeremy0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (43,'Elsa','Leavitt','elsa0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (46,'David','Lawrence','david19@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (47,'Hattie','Haemon','hattie0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (48,'Anita','Lucerne','anita0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (52,'Rebecca','Laszlo','rebecca2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (55,'Eric','Lang','eric6@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (56,'Brian','Groth','brian5@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (57,'Judy','Lundahl','judy1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (58,'Peter','Kurniawan','peter4@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (59,'Douglas','Groncki','douglas2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (60,'Sean','Lunt','sean4@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (61,'Jeffrey','Kurtz','jeffrey3@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (64,'Vamsi','Kuppa','vamsi1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (65,'Jane','Greer','jane2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (66,'Alexander','Deborde','alexander1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (70,'Deepak','Kumar','deepak0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (73,'Margaret','Krupka','margaret1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (74,'Christopher','Bright','christopher2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (75,'Aidan','Delaney','aidan0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (76,'James','Krow','james11@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (77,'Michael','Brundage','michael13@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (78,'Stefan','Delmarco','stefan0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (79,'Mitch','Kennedy','mitch0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (82,'James','Kramer','james10@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (83,'Eric','Brumfield','eric3@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (84,'Della','Demott Jr','della0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (88,'Pamala','Kotc','pamala0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (91,'Joy','Koski','joy0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (92,'Jovita','Carmody','jovita0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (93,'Prashanth','Desai','prashanth0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (94,'Scott','Konersmann','scott6@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (95,'Jane','Carmichael','jane0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (96,'Bonnie','Lepro','bonnie2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (97,'Eugene','Kogan','eugene2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (100,'Kirk','King','kirk2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (101,'William','Conner','william1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (102,'Linda','Leste','linda7@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (106,'Andrea','Thomsen','andrea1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (109,'Daniel','Thompson','daniel2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (110,'Kendra','Thompson','kendra0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (111,'Scott','Colvin','scott1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (112,'Elsie','Lewin','elsie0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (113,'Donald','Thompson','donald1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (114,'John','Colon','john14@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (115,'George','Li','george3@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (118,'Yale','Li','yale0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (119,'Phyllis','Thomas','phyllis2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (120,'Pat','Coleman','pat2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (124,'Yuhong','Li','yuhong1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (127,'Joseph','Lique','joseph2@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (128,'Judy','Thames','judy3@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (129,'Connie','Coffman','connie0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (130,'Paulo','Lisboa','paulo0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (131,'Vanessa','Tench','vanessa0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (132,'Teanna','Cobb','teanna0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (133,'Michael','Graff','michael16@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (136,'Derek','Graham','derek0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (137,'Gytis','Barzdukas','gytis0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (138,'Jane','Clayton','jane1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (142,'Jon','Grande','jon1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (145,'Ted','Bremer','ted0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (146,'Richard','Bready','richard1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (147,'Alice','Clark','alice1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (148,'Alan','Brewer','alan1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (149,'Cornelius','Brandon','cornelius0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (150,'Jill','Christie','jill1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (151,'Walter','Brian','walter0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (154,'Carlton','Carlisle','carlton0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (155,'Joseph','Castellucio','joseph1@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (156,'Lester','Bowman','lester0@adventure-works.com');
Insert into REG_APP.ATTENDEES (ID,FIRST_NAME,LAST_NAME,EMAIL_ADDRESS) values (160,'Brigid','Cavendish','brigid0@adventure-works.com');
-- INSERTING into REG_APP.EVENTS
Insert into REG_APP.EVENTS (ID,EVENT_NAME,EVENT_DESCRIPTION,EVENT_START_DATE,EVENT_PRICE,EVENT_END_DATE) values (1,'World Wide Trade','Contoso WWT is the best trade conference in the world. WWT allows import and exporters to connect with your community, and explore the latest technology.',TO_DATE('21-SEP-20','DD-MON-YY'),1200,TO_DATE('25-SEP-20','DD-MON-YY'));
-- INSERTING into REG_APP.REGISTRATIONS
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (1,TO_DATE('02-MAR-20','DD-MON-YY'),1,1);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (2,TO_DATE('03-FEB-20','DD-MON-YY'),1,2);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (5,TO_DATE('04-MAR-20','DD-MON-YY'),2,3);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (6,TO_DATE('18-MAR-20','DD-MON-YY'),2,6);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (24,TO_DATE('16-MAR-20','DD-MON-YY'),2,52);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (26,TO_DATE('16-MAR-20','DD-MON-YY'),2,41);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (27,TO_DATE('16-MAR-20','DD-MON-YY'),1,25);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (43,TO_DATE('24-MAR-20','DD-MON-YY'),2,114);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (63,TO_DATE('24-MAR-20','DD-MON-YY'),2,148);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (83,TO_DATE('25-MAR-20','DD-MON-YY'),2,56);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (85,TO_DATE('25-MAR-20','DD-MON-YY'),1,56);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (86,TO_DATE('25-MAR-20','DD-MON-YY'),2,136);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (87,TO_DATE('26-MAR-20','DD-MON-YY'),1,5);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (89,TO_DATE('26-MAR-20','DD-MON-YY'),2,5);
Insert into REG_APP.REGISTRATIONS (ID,REGISTRATION_DATE,SESSION_ID,ATTENDEE_ID) values (92,TO_DATE('26-MAR-20','DD-MON-YY'),1,95);
-- INSERTING into REG_APP.SESSIONS
Insert into REG_APP.SESSIONS (ID,NAME,DESCRIPTION,SESSION_DATE,SPEAKER_ID,EVENT_ID,DURATION) values (1,'What is the Future of Trade? Multilateral or Bilateral?','This panel will cover the “big picture” of global trade concerning the benefits and limits of multilateral trade negotiations, impact of plurilateral and bilateral agreements on the multilateral system, where we are now and prospects for global trade post COVID-19.',TO_DATE('21-SEP-20','DD-MON-YY'),1,1,60);
Insert into REG_APP.SESSIONS (ID,NAME,DESCRIPTION,SESSION_DATE,SPEAKER_ID,EVENT_ID,DURATION) values (2,'New to Trade Compliance?','You will also learn how transition can be made from Trade Compliance to Global Trade Compliance and the specific challenges involved',TO_DATE('21-SEP-20','DD-MON-YY'),2,1,60);
Insert into REG_APP.SESSIONS (ID,NAME,DESCRIPTION,SESSION_DATE,SPEAKER_ID,EVENT_ID,DURATION) values (3,'Supply Chain Logistics, Trade and Tech Talk','Are you at the forefront of technology when it comes to managing your customs and logistics data or are you worried about being left behind?',TO_DATE('29-MAR-19','DD-MON-YY'),3,1,60);
Insert into REG_APP.SESSIONS (ID,NAME,DESCRIPTION,SESSION_DATE,SPEAKER_ID,EVENT_ID,DURATION) values (4,'U.S. Trade Policies and Countries of Production in a Global Supply Chain','Trade policies and actions such as Section 232 and Section 301, even before COVID-19, have affected US importers, global manufacturers, and US resellers decisions about global sourcing and countries of production.',TO_DATE('29-MAR-19','DD-MON-YY'),4,1,60);
-- INSERTING into REG_APP.SPEAKERS
Insert into REG_APP.SPEAKERS (ID,FIRST_NAME,LAST_NAME,SPEAKER_BIO) values (1,'Anthony','Smith','When Anthony is not evaligizing Azure technologies, he is watching baseball and cheering for his favorite team. Go Mets!');
Insert into REG_APP.SPEAKERS (ID,FIRST_NAME,LAST_NAME,SPEAKER_BIO) values (2,'Julia','Whitehall','Julia leads the marketing team for Microsoft Azure, and is focused on how Microsoft presents its Applications, Infrastructure, Data and Intelligence capabilities to customers and partners. In addition to the primary focus on Azure, the team are also responsible for Microsoftâ€™s hybrid cloud assets; including SQL Server, Windows Server, Developer tools and management capabilities. Across this portfolio, Julia is responsible for the value proposition, global go to market strategy, and industry enga'
                                                                                                 'gement. She also works in partnership with engineering leadership to chart the product roadmaps. Julia joined Microsoft in 2001 as a product manager in the Enterprise Server team. In 2005, she moved to Microsoftâ€™s US sales organization to run channel marketing and sales incentives. In 2007, she returned to product leadership, taking on Exchange Server product marketing. Over the course of the next 8 years, she was instrumental in leading the productâ€™s evolution from an on-premises server technol'
                                                                                                 'ogy to establishing Office 365 as the leader in cloud productivity services. Julia has a bachelorâ€™s degree from Stanford University and a masterâ€™s in business administration from Harvard Business School.');
Insert into REG_APP.SPEAKERS (ID,FIRST_NAME,LAST_NAME,SPEAKER_BIO) values (3,'Alice','Brewer','Alice is a supply chain expert!');
Insert into REG_APP.SPEAKERS (ID,FIRST_NAME,LAST_NAME,SPEAKER_BIO) values (4,'Michael','Graham','Michael works with the US Trade Commission and helps reform trade policies');

--  DDL for Index IX_ATTENDEES_EMAIL

  CREATE UNIQUE INDEX IX_ATTENDEES_EMAIL ON REG_APP.ATTENDEES (EMAIL_ADDRESS);

--  DDL for Index IX_EVENTS_NAME

  CREATE INDEX IX_EVENTS_NAME ON REG_APP.EVENTS (EVENT_NAME);

--  DDL for Index IX_REG_SESS_ATTENDEE

  CREATE UNIQUE INDEX IX_REG_SESS_ATTENDEE ON REG_APP.REGISTRATIONS (SESSION_ID, ATTENDEE_ID);

--  DDL for Procedure GET_RANDOM_ATTENDEE

  CREATE FUNCTION REG_APP.GET_RANDOM_ATTENDEE (OUT p_attendeeid INT) RETURNS INT
LANGUAGE PLPGSQL
AS $$
BEGIN
    SELECT
        id into p_attendeeid
    FROM
        (
            SELECT
                id
            FROM
                REG_APP.attendees
            ORDER BY
                RANDOM()
			LIMIT 1
        ) AS attendees_subquery;  
END
$$;

--  DDL for Procedure REGISTER_ATTENDEE_SESSION

  CREATE OR REPLACE FUNCTION REG_APP.REGISTER_ATTENDEE_SESSION 
  (
  P_SESSION_ID INT 
, P_ATTENDEE_ID INT
, OUT STATUS INT
)
RETURNS INT
AS $$
BEGIN
    INSERT INTO REG_APP.registrations (registration_date, session_id, attendee_id) 
    VALUES (CURRENT_DATE, P_SESSION_ID, P_ATTENDEE_ID);
	
	SELECT 1 INTO STATUS;
END
$$ LANGUAGE plpgsql;

-- create collations
CREATE COLLATION reg_app."C" FROM pg_catalog."C";

-- create  a domain
CREATE DOMAIN color VARCHAR(10)
CHECK (VALUE IN ('red', 'green', 'blue'));

-- create a type
CREATE TYPE address AS
   (
       city VARCHAR(90),
       street VARCHAR(90),
	   state VARCHAR(90),
	   zip VARCHAR(90),
	   country VARCHAR(90)
   );

-- create rule
CREATE OR REPLACE RULE protect_data AS
  ON UPDATE TO reg_app.registrations  
  WHERE OLD.attendee_id = 1
  DO INSTEAD NOTHING;

-- create sequence
CREATE SEQUENCE mysequence
INCREMENT 5
START 10;

-- create trigger function
CREATE OR REPLACE FUNCTION attendee_insert_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
    INSERT INTO Reg_App.Attendees_Audit ( "Id", "LastName", "FirstName","EmailAddress", "AuditDate")
         VALUES(NEW."Id",NEW."LastName",NEW."FirstName",NEW.EmailAddress, current_user,current_date);

RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER attendee_insert_trigger
  AFTER INSERT
  ON Reg_App.Attendees
  FOR EACH ROW
  EXECUTE PROCEDURE attendee_insert_trigger_fnc();

-- Create Functions
CREATE OR REPLACE FUNCTION REG_APP.hello_world() RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN 'Hello World';
END
$$;

-- Create publication
CREATE PUBLICATION app_pub WITH (publish = 'insert, update, delete');

-- create event triggers
CREATE OR REPLACE FUNCTION log_ddl()
  RETURNS event_trigger AS $$
DECLARE
  audit_query TEXT;
  r RECORD;
BEGIN
  IF tg_tag <> 'DROP TABLE'
  THEN
   FOR r IN SELECT * FROM pg_event_trigger_ddl_commands() 
    LOOP
      INSERT INTO Reg_App.ddl_history (ddl_date, ddl_tag, object_name) VALUES (statement_timestamp(), tg_tag, r.object_identity);
    END LOOP;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION log_ddl_drop()
  RETURNS event_trigger AS $$
DECLARE
  audit_query TEXT;
  r RECORD;
BEGIN
  IF tg_tag = 'DROP TABLE'
  THEN
    FOR r IN SELECT * FROM pg_event_trigger_ddl_commands() 
    LOOP
      INSERT INTO Reg_App.ddl_history (ddl_date, ddl_tag, object_name) VALUES (statement_timestamp(), tg_tag, r.object_identity);
    END LOOP;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER log_ddl_info ON ddl_command_end EXECUTE PROCEDURE log_ddl();
CREATE EVENT TRIGGER log_ddl_drop_info ON sql_drop EXECUTE PROCEDURE log_ddl_drop();

--  Constraints for Table REGISTRATIONS

  ALTER TABLE REG_APP.REGISTRATIONS ALTER COLUMN ATTENDEE_ID SET NOT NULL;
  ALTER TABLE REG_APP.REGISTRATIONS ALTER COLUMN SESSION_ID SET NOT NULL;
  ALTER TABLE REG_APP.REGISTRATIONS ALTER COLUMN REGISTRATION_DATE SET NOT NULL;
  ALTER TABLE REG_APP.REGISTRATIONS ADD PRIMARY KEY (ID);
  ALTER TABLE REG_APP.REGISTRATIONS ALTER COLUMN ID SET NOT NULL;
  CREATE SEQUENCE reg_app_seq;
  ALTER TABLE REG_APP.REGISTRATIONS ALTER COLUMN ID SET DEFAULT nextval('reg_app_seq');
  ALTER SEQUENCE reg_app_seq RESTART WITH 103;

--  Constraints for Table SESSIONS

  ALTER TABLE REG_APP.SESSIONS ALTER COLUMN SPEAKER_ID SET NOT NULL;
  ALTER TABLE REG_APP.SESSIONS ALTER COLUMN EVENT_ID SET NOT NULL;
  ALTER TABLE REG_APP.SESSIONS ALTER COLUMN NAME SET NOT NULL;
  ALTER TABLE REG_APP.SESSIONS ALTER COLUMN ID SET NOT NULL;
  ALTER TABLE REG_APP.SESSIONS ADD PRIMARY KEY (ID);

--  Constraints for Table EVENTS

  ALTER TABLE REG_APP.EVENTS ALTER COLUMN EVENT_START_DATE SET NOT NULL;
  ALTER TABLE REG_APP.EVENTS ALTER COLUMN EVENT_NAME SET NOT NULL;
  ALTER TABLE REG_APP.EVENTS ALTER COLUMN ID SET NOT NULL;
  ALTER TABLE REG_APP.EVENTS ADD PRIMARY KEY (ID);

--  Constraints for Table ATTENDEES
  
  ALTER TABLE REG_APP.ATTENDEES ALTER COLUMN ID SET NOT NULL;
  ALTER TABLE REG_APP.ATTENDEES ADD PRIMARY KEY (ID);

--  Constraints for Table SPEAKERS

  ALTER TABLE REG_APP.SPEAKERS ALTER COLUMN LAST_NAME SET NOT NULL;
  ALTER TABLE REG_APP.SPEAKERS ALTER COLUMN FIRST_NAME SET NOT NULL;
  ALTER TABLE REG_APP.SPEAKERS ALTER COLUMN ID SET NOT NULL;
  ALTER TABLE REG_APP.SPEAKERS ADD PRIMARY KEY (ID);

--  Ref Constraints for Table REGISTRATIONS

  ALTER TABLE REG_APP.REGISTRATIONS ADD FOREIGN KEY (ATTENDEE_ID)
	  REFERENCES REG_APP.ATTENDEES (ID);
  ALTER TABLE REG_APP.REGISTRATIONS ADD FOREIGN KEY (SESSION_ID)
	  REFERENCES REG_APP.SESSIONS (ID);

--  Ref Constraints for Table SESSIONS

  ALTER TABLE REG_APP.SESSIONS ADD FOREIGN KEY (EVENT_ID)
	  REFERENCES REG_APP.EVENTS (ID);
  ALTER TABLE REG_APP.SESSIONS ADD FOREIGN KEY (SPEAKER_ID)
	  REFERENCES REG_APP.SPEAKERS (ID);


      