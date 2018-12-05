package com.dnastack.dictator;

import java.util.HashMap;
import java.util.Map;

import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;

import lombok.extern.jbosslog.JBossLog;

@ApplicationPath("/")
@JBossLog
public class DictatorApplication extends Application {

    public static final String VERSION_PROP = "APP_VERSION";
    public static final String CENSORSHIP_DURATION_PROP = "CENSORSHIP_DURATION";

    @Override
    public Map<String, Object> getProperties() {
        Map<String, Object> props = new HashMap<>(super.getProperties());
        props.put(VERSION_PROP, System.getenv(VERSION_PROP));
        props.put(CENSORSHIP_DURATION_PROP, Long.parseLong(System.getenv(CENSORSHIP_DURATION_PROP)));
        log.infov("Initialized version {0}", props.get(VERSION_PROP));
        return props;
    }
}
