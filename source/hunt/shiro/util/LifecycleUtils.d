module hunt.shiro.util.LifecycleUtils;

import hunt.shiro.util.Common;

import hunt.collection.Collection;
import hunt.logging;


/**
 * Utility class to help call {@link hunt.shiro.util.Initializable#init() Initializable.init()} and
 * {@link hunt.shiro.util.Destroyable#destroy() Destroyable.destroy()} methods cleanly on any object.
 *
 * @since 0.2
 */
abstract class LifecycleUtils {

    // static void init(Object o) {
    //     if (o instanceof Initializable) {
    //         init((Initializable) o);
    //     }
    // }

    // static void init(Initializable initializable) {
    //     initializable.init();
    // }

    // /**
    //  * Calls {@link #init(Object) init} for each object in the collection.  If the collection is {@code null} or empty,
    //  * this method returns quietly.
    //  *
    //  * @param c the collection containing objects to {@link #init init}.
    //  * @throws ShiroException if unable to initialize one or more instances.
    //  * @since 0.9
    //  */
    // static void init(Collection c) {
    //     if (c == null || c.isEmpty()) {
    //         return;
    //     }
    //     for (Object o : c) {
    //         init(o);
    //     }
    // }

    static void destroy(Object o) {
        Destroyable d = cast(Destroyable)o;
        if (d !is null) {
            destroy(d);
        } else {
            Collection!Object c = cast(Collection!Object)o;
            if (c !is null) {
                destroy(c);
            }
        }
    }

    static void destroy(Destroyable d) {
        if (d != null) {
            try {
                d.destroy();
            } catch (Throwable t) {
                version(HUNT_DEBUG) {
                    string msg = "Unable to cleanly destroy instance [" ~ 
                        (cast(Object)d).toString() ~ "] of type [" ~ 
                        (cast(Object)d).name ~ "].";
                    trace(msg, t);
                }
            }
        }
    }

    /**
     * Calls {@link #destroy(Object) destroy} for each object in the collection.
     * If the collection is {@code null} or empty, this method returns quietly.
     *
     * @param c the collection of objects to destroy.
     * @since 0.9
     */
    static void destroy(Collection!Object c) {
        if (c is null || c.isEmpty()) {
            return;
        }

        foreach (Object o ; c) {
            destroy(o);
        }
    }
}