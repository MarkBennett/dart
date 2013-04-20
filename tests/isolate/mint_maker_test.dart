// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Things that should be "auto-generated" are between AUTO START and
// AUTO END (or just AUTO if it's a single line).

library MintMakerTest;
import 'dart:isolate';
import '../../pkg/unittest/lib/unittest.dart';

class Mint {
  Mint() : registry_ = new Map<SendPort, Purse>() {
    // AUTO START
    ReceivePort mintPort = new ReceivePort();
    port = mintPort.toSendPort();
    serveMint(mintPort);
    // AUTO END
  }

  // AUTO START
  void serveMint(ReceivePort port) {
    port.receive((var message, SendPort replyTo) {
      int balance = message;
      Purse purse = createPurse(balance);
      replyTo.send([ purse.port ], null);
    });
  }
  // AUTO END

  Purse createPurse(int balance) {
    Purse purse = new Purse(this, balance);
    registry_[purse.port] = purse;
    return purse;
  }

  Purse lookupPurse(SendPort port) {
    return registry_[port];
  }

  Map<SendPort, Purse> registry_;
  // AUTO
  SendPort port;
}


// AUTO START
class MintWrapper {
  MintWrapper(SendPort this.mint_) {}

  void createPurse(int balance, handlePurse(PurseWrapper purse)) {
    mint_.call(balance).then((var message) {
      SendPort purse = message[0];
      handlePurse(new PurseWrapper(purse));
    });
  }

  SendPort mint_;
}
// AUTO END


/*
One way this could look without the autogenerated code:

class Mint {
  Mint() : registry_ = new Map<SendPort, Purse>() {
  }

  wrap Purse createPurse(int balance) {
    Purse purse = new Purse(this, balance);
    registry_[purse.port] = purse;
    return purse;
  }

  Purse lookupPurse(SendPort port) {
    return registry_[port];
  }

  Map<SendPort, Purse> registry_;
}

The other end of the port would use Wrapper<Mint> as the wrapper, or
Future<Mint> as a future for the wrapper.
*/


class Purse {
  Purse(Mint this.mint, int this.balance) {
    // AUTO START
    ReceivePort recipient = new ReceivePort();
    port = recipient.toSendPort();
    servePurse(recipient);
    // AUTO END
  }

  // AUTO START
  void servePurse(ReceivePort recipient) {
    recipient.receive((var message, SendPort replyTo) {
      String command = message[0];
      if (command == "balance") {
        replyTo.send(queryBalance(), null);
      } else if (command == "deposit") {
        Purse source = mint.lookupPurse(message[2]);
        deposit(message[1], source);
      } else if (command == "sprout") {
        Purse result = sproutPurse();
        replyTo.send([ result.port ], null);
      } else {
        // TODO: Send an exception back.
        replyTo.send("Exception: Command not understood", null);
      }
    });
  }
  // AUTO END

  int queryBalance() { return balance; }

  Purse sproutPurse() { return mint.createPurse(0); }

  void deposit(int amount, Purse source) {
    // TODO: Throw an exception if the source purse doesn't hold
    // enough dough.
    balance += amount;
    source.balance -= amount;
  }

  Mint mint;
  int balance;
  // AUTO
  SendPort port;
}


// AUTO START
class PurseWrapper {
  PurseWrapper(SendPort this.purse_) {}

  void queryBalance(handleBalance(int balance)) {
    purse_.call([ "balance" ]).then((var message) {
      int balance = message;
      handleBalance(balance);
    });
  }

  void sproutPurse(handleSprouted(PurseWrapper sprouted)) {
    purse_.call([ "sprout" ]).then((var message) {
      SendPort sprouted = message[0];
      handleSprouted(new PurseWrapper(sprouted));
    });
  }

  void deposit(PurseWrapper source, int amount) {
    purse_.send([ "deposit", amount, source.purse_ ], null);
  }


  SendPort purse_;
}
// AUTO END


// AUTO STATUS UNCLEAR!

mintMakerWrapper() {
  port.receive((var message, SendPort replyTo) {
    Mint mint = new Mint();
    replyTo.send([ mint.port ], null);
  });
}

class MintMakerWrapper {
  MintMakerWrapper() {
    port_ = spawnFunction(mintMakerWrapper);
  }

  void makeMint(handleMint(MintWrapper mint)) {
    port_.call(null).then((var message) {
      SendPort mint = message[0];
      handleMint(new MintWrapper(mint));
    });
  }

  SendPort port_;
}

_checkBalance(PurseWrapper wrapper, expected) {
  wrapper.queryBalance(expectAsync1((int balance) {
    expect(balance, equals(expected));
  }));
}

main() {
  test("creating purse, deposit, and query balance", () {
    MintMakerWrapper mintMaker = new MintMakerWrapper();
    mintMaker.makeMint(expectAsync1((MintWrapper mint) {
      mint.createPurse(100, expectAsync1((PurseWrapper purse) {
        _checkBalance(purse, 100);
        purse.sproutPurse(expectAsync1((PurseWrapper sprouted) {
          _checkBalance(sprouted, 0);
          _checkBalance(purse, 100);

          sprouted.deposit(purse, 5);
          _checkBalance(sprouted, 0 + 5);
          _checkBalance(purse, 100 - 5);

          sprouted.deposit(purse, 42);
          _checkBalance(sprouted, 0 + 5 + 42);
          _checkBalance(purse, 100 - 5 - 42);
        }));
      }));
    }));
  });

  /* This is an attempt to show how the above code could look like if we had
   * better language support for asynchronous messages (deferred/asynccall).
   * The static helper methods like createPurse and queryBalance would also
   * have to be marked async.

  void run(port) {
    MintMakerWrapper mintMaker = spawnMintMaker();
    deferred {
      MintWrapper mint = asynccall mintMaker.createMint();
      PurseWrapper purse = asynccall mint.createPurse(100);
      expect(asynccall purse.queryBalance(), 100);

      PurseWrapper sprouted = asynccall purse.sproutPurse();
      expect(asynccall sprouted.queryBalance(), 0);

      asynccall sprouted.deposit(purse, 5);
      expect(asynccall sprouted.queryBalance(), 0 + 5);
      expect(asynccall purse.queryBalance(), 100 - 5);

      asynccall sprouted.deposit(purse, 42);
      expect(asynccall sprouted.queryBalance(), 0 + 5 + 42);
      expect(asynccall purse.queryBalance(), 100 - 5 - 42);
    }
  }
  */

  /* And a version using futures and wrappers.

  void run(port) {
    Wrapper<MintMaker> mintMaker = spawnMintMaker();
    Future<Mint> mint = mintMaker...createMint();
    Future<Purse> purse = mint...createPurse(100);
    expect(purse.queryBalance(), 100);

    Future<Purse> sprouted = purse...sproutPurse();
    expect(0, sprouted.queryBalance());

    sprouted...deposit(purse, 5);
    expect(sprouted.queryBalance(), 0 + 5);
    expect(purse.queryBalance(), 100 - 5);

    sprouted...deposit(purse, 42);
    expect(sprouted.queryBalance(), 0 + 5 + 42);
    expect(purse.queryBalance(), 100 - 5 - 42);
  }
  */
}
