package com.centzy.util.concurrent;

import java.util.concurrent.Callable;

/**
 * @author peter@locality.com (Peter Edge)
 */
public class LazyLoaderDelegate {

  private final Callable<Object> callable;

  private volatile Object object;

  public LazyLoaderDelegate(Callable<Object> callable) {
    this.callable = callable;
  }

  public Object get() throws Exception {
    Object result = object;
    if (result == null) {
      synchronized (this) {
        result = object;
        if (result == null) {
          object = result = callable.call();
        }
      }
    }
    return result;
  }
}
