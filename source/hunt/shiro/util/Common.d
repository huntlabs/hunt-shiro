module hunt.shiro.util.Common;


/**
 * Shiro container-agnostic interface that indicates that this object requires initialization.
 *
 * @since 0.2
 */
interface Initializable {

    /**
     * Initializes this object.
     *
     * @throws hunt.shiro.ShiroException
     *          if an exception occurs during initialization.
     */
    void init();

}


/**
 * Interface implemented by components that can be named, such as via configuration, and wish to have that name
 * set once it has been configured.
 *
 * @since 0.9
 */
interface Nameable {

    /**
     * Sets the (preferably application unique) name for this component.
     * @param name the preferably application unique name for this component.
     */
    void setName(string name);
}
