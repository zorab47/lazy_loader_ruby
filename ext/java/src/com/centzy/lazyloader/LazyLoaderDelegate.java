package com.centzy.lazyloader;

import java.util.concurrent.Callable;

/**
 * @author Peter Edge (peter@locality.com).
 */
public class LazyLoaderDelegate {

  private final Callable<Object> callable;

  private volatile LazyLoaderResult lazyLoaderResult;

  public LazyLoaderDelegate(Callable<Object> callable) {
    this.callable = callable;
  }

  public Object get() {
    LazyLoaderResult result = lazyLoaderResult;
    if (result == null) {
      synchronized (this) {
        result = lazyLoaderResult;
        if (result == null) {
          try {
            lazyLoaderResult = result = new LazyLoaderResult(callable.call(), null);
          } catch (Exception e) {
            lazyLoaderResult = result = new LazyLoaderResult(null, new RuntimeException(e));
          }
        }
      }
    }
    return result.get();
  }

  private static class LazyLoaderResult {

    private final Object object;
    private final RuntimeException runtimeException;

    LazyLoaderResult(Object object, RuntimeException runtimeException) {
      this.object = object;
      this.runtimeException = runtimeException;
    }

    Object get() {
      if (runtimeException != null) {
        throw runtimeException;
      }
      return object;
    }
  }
}
