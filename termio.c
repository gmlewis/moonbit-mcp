#include <stdio.h>
#include <termios.h>
#include <unistd.h>

// Set terminal to raw mode (disable line buffering)
void set_raw_mode()
{
  struct termios term;
  tcgetattr(STDIN_FILENO, &term);
  // term.c_lflag &= ~(ICANON | ECHO);
  term.c_lflag &= ~(ICANON); // keep echo so user can see what they type
  tcsetattr(STDIN_FILENO, TCSANOW, &term);
}

// Restore default terminal settings
void restore_terminal()
{
  struct termios term;
  tcgetattr(STDIN_FILENO, &term);
  term.c_lflag |= (ICANON | ECHO); // Re-enable canonical mode & echo
  tcsetattr(STDIN_FILENO, TCSANOW, &term);
}

/*
int main()
{
  set_raw_mode(); // Disable line buffering
  printf("Press any key (no Enter needed): ");
  int c = getchar();  // Read immediately
  restore_terminal(); // Restore default behavior
  printf("\nYou pressed: %c\n", c);
  return 0;
}
*/