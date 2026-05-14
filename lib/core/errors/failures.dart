abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure     extends Failure { const ServerFailure([String m = 'Server error'])          : super(m); }
class NetworkFailure    extends Failure { const NetworkFailure([String m = 'No internet connection']): super(m); }
class AuthFailure       extends Failure { const AuthFailure([String m = 'Authentication failed'])   : super(m); }
class CacheFailure      extends Failure { const CacheFailure([String m = 'Cache error'])            : super(m); }
class ValidationFailure extends Failure { const ValidationFailure(String m)                         : super(m); }
class NotFoundFailure   extends Failure { const NotFoundFailure([String m = 'Not found'])           : super(m); }
class UnknownFailure    extends Failure { const UnknownFailure([String m = 'Unknown error'])        : super(m); }
