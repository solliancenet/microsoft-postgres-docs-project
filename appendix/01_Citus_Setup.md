# Appendix B: Citus (Multi-Tenant) App Configuration

This document demonstrates how to develop an application that leverages Azure Database for PostgreSQL (Citus).

## Setup

We recommend that you follow instructions in the [Setup](00_Setup.md) document first. That document will guide you through the process of configuring your VM for local development, and deploying a Java API and Angular client app to an Azure landing zone.

Sai TODO: Tell the user to run the Citus setup script. Tell them to assign appropriate access to conferenceuser.

## App Comparison

To understand how the multi-tenant app functions, compare it to the single-tenant app deployed previously.

### Database Changes

The multi-tenant sample app targets Azure Database for PostreSQL (Citus). Citus instances consist of multiple nodes, which allow for horizontal scaling. However, to applications, the Citus instance appears as one database. This feature allows developers to take advantage of the features of relational databases, while providing the scale needed to support large, multi-tenant applications.

To optimize the performance of this configuration, locate all data belonging to one tenant on a single node. This strategy offers performance benefits (avoiding unnecessary network requests) and allows Citus to enforce constraints, a key advantage of SQL databases.

The modified Citus schema consists of a `companies` table, and each table used by the application contains a `company_id` column. 

```sql
-- Not all constraints shown in this code sample

-- Tenants
CREATE TABLE reg_app.companies (
	ID serial PRIMARY KEY,
	Name varchar(50) NOT NULL
);

-- Sessions table used by the application
CREATE TABLE REG_APP.SESSIONS (	
    ID INT,
	COMPANY_ID INT,
	NAME VARCHAR(300), 
	DESCRIPTION VARCHAR(2000), 
	SESSION_DATE TIMESTAMP, 
	SPEAKER_ID INT, 
	EVENT_ID INT, 
	DURATION DECIMAL
); 
```

It is relatively easy to account for this new `company_id` column using the DML `UPDATE` statement. Each session references an event, hence the reference to the `events` table.

```sql
UPDATE REG_APP.SESSIONS
SET COMPANY_ID = events.company_id
FROM reg_app.events 
WHERE sessions.event_id = events.id;
```

The code samples indicated above solve the issue of co-location: with the `company_id` column, Citus easily identifies the owner (tenant) of each row in all application tables in the relational data model. However, to protect referential integrity, Citus requires developers to include the *distribution column* -- `company_id` in this scenario -- in composite primary and foreign keys.

```sql
-- Composite primary key for sessions table
ALTER TABLE REG_APP.SESSIONS ADD PRIMARY KEY (COMPANY_ID, ID);

-- Composite foreign keys for sessions table
ALTER TABLE REG_APP.SESSIONS ADD FOREIGN KEY (COMPANY_ID, EVENT_ID)
    REFERENCES REG_APP.EVENTS (COMPANY_ID, ID);
ALTER TABLE REG_APP.SESSIONS ADD FOREIGN KEY (COMPANY_ID, SPEAKER_ID)
    REFERENCES REG_APP.SPEAKERS (COMPANY_ID, ID);
```

Note that this also applies to `UNIQUE` constraints. The SQL below does not directly relate to the `sessions` table, but it enforces that each attendee can enroll for a given session only once.

```sql
CREATE UNIQUE INDEX IX_REG_SESS_ATTENDEE ON REG_APP.REGISTRATIONS (COMPANY_ID, SESSION_ID, ATTENDEE_ID);
```

At the end of this guide, we will use the functions provided by the Citus extension in Azure to support our changes.

### Application Changes

To support the database schema changes, the Java backend has been modified appropriately.

While the Angular frontend has been modified (all URL routes are prefaced with the company ID), that is not the focus of this section.

First, all database requests must be filtered by the `company_id` column. Hence, each model class has been annotated with the `@Filter()` Java annotation. 

```Java
@Filter(name = "TenantFilter", condition = "company_id = :tenantId")
```

The filter references a `tenantId` value. To provide this value on every request to the database, the application leverages AspectJ. The `@Before()` annotation intercepts method calls to `AttendeeService` objects. The `addFilter()` method then appends the `tenantId` filter parameter to requests.

```Java
@Before("execution(* com.yourcompany.conferencedemo.services.AttendeeService.*(..)) && target(attendeeService)")
public void addFilter(JoinPoint pjp, AttendeeService attendeeService)
{
    org.hibernate.Filter filter = attendeeService.entityManager.unwrap(Session.class).enableFilter("TenantFilter");
    filter.setParameter("tenantId", TenantContext.getCurrentTenant());
    filter.validate();
}
```
>**Note**: In the multi-tenant app, injected service classes handle database operations for API controllers; the API controllers themselves do not make calls to repository methods.

The API initiates a thread to handle each request. So, the `TenantContext` class exposes the thread-specific value of the current tenant.

Sai TODO: Demonstrate both ways of obtaining a particular record. Show performance difference if there is time.

## Run the Sample App Locally

Sai TODO

## Data Migration

Sai TODO

## Complete Citus Configuration

Sai TODO

## Migrate App to Azure and Test

Sai TODO