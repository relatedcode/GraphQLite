import { RedisPubSub } from "graphql-redis-subscriptions";
import Redis from "ioredis";

const options: any = {
  db: 1,
  host: process.env.CACHE_HOST,
  port: process.env.CACHE_PORT as any,
  password: process.env.CACHE_PASSWORD,
  retryStrategy: (times: number) => {
    // reconnect after
    return Math.min(times * 50, 2000);
  },
};

const pubsub = new RedisPubSub({
  publisher: new Redis(options),
  subscriber: new Redis(options),
});

export default pubsub;
