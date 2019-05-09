module hunt.shiro.util.Common;


extern(C) bool _d_isbaseof(ClassInfo child, ClassInfo parent);

/**
 * Shiro container-agnostic interface that indicates that this object requires a callback during destruction.
 *
 * @since 0.2
 */
interface Destroyable {

    /**
     * Called when this object is being destroyed, allowing any necessary cleanup of internal resources.
     *
     * @throws Exception if an exception occurs during object destruction.
     */
    void destroy();

}

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
