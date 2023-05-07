create table if not exists "objects"(
  "objectId" varchar(255) primary key,
  "text" text,
  "number" integer,
  "double" real,
  "boolean" boolean,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);