import 'package:beamer/beamer.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:gpt4client/api/client_api.dart';
import 'package:gpt4client/screen/main_screen.dart';

class MainLocation extends BeamLocation<BeamState>{
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(child: MainScreen(), title:"Home", key : ValueKey('home-${DateTime.now()}'))
    ];
  }

  @override
  List<Pattern> get pathPatterns => ['/main/*'];

  @override
  List<BeamGuard> get guards => [...super.guards, BeamGuard(
  // on which path patterns (from incoming routes) to perform the check
  pathPatterns: ['/login'],
  // perform the check on all patterns that **don't** have a match in pathPatterns
  guardNonMatching: true,
  // return false to redirect
  check: (context, location) => ClientAPI().hasToken(),
  // where to redirect on a false check
  beamToNamed: (origin, target) => '/login',
  )];

}