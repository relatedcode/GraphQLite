import redis from "redis";
import { promisify } from "util";
const client = redis.createClient({
  host: process.env.CACHE_HOST,
  port: process.env.CACHE_PORT as any,
  password: process.env.CACHE_PASSWORD,
  db: 0,
});

client.on("connect", () => {
  console.log("Redis client connected");
});

client.on("error", (error: any) => {
  console.error(error);
});

const get = promisify(client.get).bind(client) as any;
const set = promisify(client.set).bind(client) as any;
const del = promisify(client.del).bind(client) as any;
const setex = promisify(client.setex).bind(client) as any;
const rpush = promisify(client.rpush).bind(client) as any;
const expire = promisify(client.expire).bind(client) as any;
const lrange = promisify(client.lrange).bind(client) as any;
const lrem = promisify(client.lrem).bind(client) as any;
const flushall = promisify(client.flushall).bind(client) as any;

export { get, set, del, setex, rpush, expire, lrange, lrem, flushall };
