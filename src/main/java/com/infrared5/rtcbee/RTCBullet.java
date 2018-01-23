package com.infrared5.rtcbee;

import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

import org.apache.commons.lang3.StringUtils;

public class RTCBullet implements Runnable {

  private boolean doRun;
  private final int order;
  public final String description;
  private int timeout = 10; // seconds

  private String host = "0.0.0.0";
  private int port = 8554;
  private String contextPath = "";
  private String streamName = "stream1";

  private IBulletCompleteHandler completeHandler;
  private IBulletFailureHandler failHandler;
  public AtomicBoolean completed = new AtomicBoolean(false);
  volatile boolean connectionException;
  private Future<?> future;

  @SuppressWarnings("unused")
  public void run() {
      Red5Bee.submit(new Runnable() {
          public void run() {
              System.out.printf("Successful subscription of bullet, disposing: bullet #%d\n", order);
              if (completed.compareAndSet(false, true)) {
              	if (completeHandler != null) {
              		completeHandler.OnBulletComplete();
                }
              }
          }
      }, timeout, TimeUnit.SECONDS);
  }

  public void stop() {
    doRun = false;
  }

  public boolean isRunnning() {
    return doRun;
  }

  public String getHost() {
    return host;
  }

  public void setHost(String host) {
    this.host = host;
  }

  public int getPort() {
    return port;
  }

  public void setPort(int port) {
    this.port = port;
  }

  public String getContextPath() {
    return contextPath;
  }

  public void setContextPath(String contextPath) {
    this.contextPath = contextPath;
  }

  public String getStreamName() {
    return streamName;
  }

  public void setStreamName(String streamName) {
    this.streamName = streamName;
  }
  
  public void setCompleteHandler(IBulletCompleteHandler completeHandler) {
      this.completeHandler = completeHandler;
  }

  public void setFailHandler(IBulletFailureHandler failHandler) {
      this.failHandler = failHandler;
  }

	/**
	 * Constructs a bullet which represents an RTC Client.
	 *
	 * @param url
	 * @param port
	 * @param application
	 * @param streamName
	 */
	private RTCBullet(int order, String url, int port, String application, String streamName) {
	    this.order = order;
	    this.host = url;
	    this.port = port;
	    this.contextPath = application;
	    this.streamName = streamName;
	    this.description = toString();
	}
	
	/**
	 * Constructs a bullet which represents an RTC Client.
	 *
	 * @param url
	 * @param port
	 * @param application
	 * @param streamName
	 * @param timeout
	 */
	private RTCBullet(int order, String url, int port, String application, String streamName, int timeout) {
	    this(order, url, port, application, streamName);
	    this.timeout = timeout;
	}
	
	public String toString() {
	    return StringUtils.join(new String[] { "(bullet #" + this.order + ")", "URL: " + this.host, "PORT: " + this.port, "APP: " + this.contextPath, "NAME: " + this.streamName }, "\n");
	}

	static final class Builder {

        static RTCBullet build(int order, String url, int port, String application, String streamName) {
            return new RTCBullet(order, url, port, application, streamName);
        }

        static RTCBullet build(int order, String url, int port, String application, String streamName, int timeout) {
            return new RTCBullet(order, url, port, application, streamName, timeout);
        }

    }

}
