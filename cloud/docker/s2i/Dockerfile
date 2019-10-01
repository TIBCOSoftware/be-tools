#
# Dockerfile for s2i builder image
#

ARG BE_TAG
ARG ARG_VERSION
ARG BE_PRODUCT_IMAGE_VERSION

#FROM com.tibco.be:5.6.0-v01
FROM "$BE_TAG":"$ARG_VERSION"-"$BE_PRODUCT_IMAGE_VERSION"

# Defines the location of the S2I
LABEL io.openshift.s2i.scripts-url=image:///usr/local/s2i

# Copy the S2I scripts from ./.s2i/bin/ to /usr/local/s2i when making the builder image
COPY s2i/assemble /usr/local/s2i/assemble
COPY s2i/usage /usr/local/s2i/usage

RUN cp /home/tibco/be/run /usr/local/s2i/run
RUN chmod 777 /usr/local/s2i/assemble
RUN chmod 777 /usr/local/s2i/usage

CMD ["/usr/local/s2i/usage"]
