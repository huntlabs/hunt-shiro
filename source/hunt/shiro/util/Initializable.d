module hunt.shiro.util.Initializable;


/**
 * Shiro container-agnostic interface that indicates that this object requires initialization.
 *
 * @since 0.2
 */
public interface Initializable {

    /**
     * Initializes this object.
     *
     * @throws org.apache.shiro.ShiroException
     *          if an exception occurs during initialization.
     */
    void init();

}
