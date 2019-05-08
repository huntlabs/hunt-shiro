module hunt.shiro.util.Destroyable;


/**
 * Shiro container-agnostic interface that indicates that this object requires a callback during destruction.
 *
 * @since 0.2
 */
public interface Destroyable {

    /**
     * Called when this object is being destroyed, allowing any necessary cleanup of internal resources.
     *
     * @throws Exception if an exception occurs during object destruction.
     */
    void destroy();

}
