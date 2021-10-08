run_query =
  fn query_def ->
    Process.sleep(2000) # simulate something taking a long time
    "result of #{query_def}"
  end

# Create a new process using the spawn/1 function
# It takes a zero arity lambda as its argument and returns a PID identifier

spawn(fn -> IO.puts(run_query.("query 1")) end)

# a pid is immediately returned, and 2 seconds later "result of query 1" is printed

# async lambda helper concurrently runs the query and prints the result

async_query =
  fn query_def ->
    spawn(fn -> IO.puts(run_query.(query_def)) end)
  end

async_query.("query 1")

# pid immediately returns
# two seconds later, "result of query 1"

# this demonstrates an important technique: passing data to the created process.
# the function takes one argument and binds it to the query_def variable.
# the data is then passed to the newly created process via the closure mechanism
# the inner lambda runs ins a separate process and refereneces
# the variable from the outer scope.

Enum.each(1..5, &async_query.("query #{&1}"))

# :ok is returned immediately
# two seconds later, 5 statements are printed!

# reminder: :ok is an atom and can be pattern matched.

ok = :ok = Enum.each(1..5, &async_query.("query #{&1}"))
ok # :ok

# even if the pattern is not matched, 5 result messages are printed

error = :ok = Enum.each(1..5, &async_query.("query #{&1}"))

# sometimes "fire and forget" style concurrency isn't good enough
# and we want to return the data from the spawned processes to the caller process

# the process mailbox (the queue of anything that can be stored in a variable)
# is a FIFO queue limited only by available memory.

# to send a message to a process you need to have its pid.

this_pid = async_query.("test 123")
send(this_pid, {:an, :arbitrary, :term})

# the consequence of the send function is a message is placed in the receiver's mailbox
# and the caller continues to do something else

# on the receiver side, pulling a message out of the mailbox is acheived with the receive expression:

# receive do
#   pattern_1 -> do_something
#   pattern_2 -> do_something
# end

# the receive expression works like the case expression
# it receives a variable and executes the first bit of code where it matches the pattern

# test it by making the shell send a message to itself
# send(self(), "a message")