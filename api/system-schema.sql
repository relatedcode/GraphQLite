create table if not exists "gql_users" (
  "objectId" varchar(255) primary key,
  "email" varchar(255) not null unique,
  "passwordHash" varchar(255) not null,
  "isDeleted" boolean not null default false,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

create table if not exists "gql_admins" (
  "objectId" varchar(255) primary key,
  "email" varchar(255) not null unique,
  "passwordHash" varchar(255) not null,
  "isDeleted" boolean not null default false,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);