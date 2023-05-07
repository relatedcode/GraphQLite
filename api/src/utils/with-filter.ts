import { $$asyncIterator } from "iterall";

export type FilterFn = (
  rootValue?: any,
  args?: any,
  context?: any,
  info?: any
) => boolean | Promise<boolean>;
export type ResolverFn = (
  rootValue?: any,
  args?: any,
  context?: any,
  info?: any
) => AsyncIterator<any>;

interface IterallAsyncIterator<T> extends AsyncIterator<T> {
  [$$asyncIterator](): IterallAsyncIterator<T>;
}

export const withFilter = (
  asyncIteratorFn: ResolverFn,
  filterFn: FilterFn
): ResolverFn => {
  return (
    rootValue: any,
    args: any,
    context: any,
    info: any
  ): IterallAsyncIterator<any> => {
    const asyncIterator: any = asyncIteratorFn(rootValue, args, context, info);

    const getNextPromise = () => {
      return new Promise<IteratorResult<any>>((resolve, reject) => {
        const inner = () => {
          asyncIterator
            .next()
            .then((payload: any) => {
              if (payload.done === true) {
                resolve(payload);
                return;
              }
              Promise.resolve(filterFn(payload.value, args, context, info))
                .catch(() => false) // We ignore errors from filter function
                .then((filterResult) => {
                  if (filterResult === true) {
                    resolve(payload);
                    return;
                  }
                  // Skip the current value and wait for the next one
                  inner();
                  return;
                });
            })
            .catch((err: any) => {
              reject(err);
              return;
            });
        };

        inner();
      });
    };

    const asyncIterator2 = {
      next() {
        return getNextPromise();
      },
      return() {
        return asyncIterator.return();
      },
      throw(error: any) {
        return asyncIterator.throw(error);
      },
      [$$asyncIterator]() {
        return this;
      },
    };

    return asyncIterator2;
  };
};
