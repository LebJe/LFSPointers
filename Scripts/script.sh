if [[ $TRAVIS_OS_NAME = 'linux' ]]; then
  # What to do in Ubunutu
  RELEASE_DOT=$(lsb_release -r)
  RELEASE_NUM=$(cut -f2 <<< "$RELEASE_DOT")
  export PATH="${PWD}/swift-${SWIFT_VER}-RELEASE-ubuntu${RELEASE_NUM}/usr/bin:$PATH"
fi

swift build
swift test