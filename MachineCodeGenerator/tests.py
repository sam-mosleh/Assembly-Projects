import unittest

from MachineCodeGenerator import (InstructionNotFound, branch_instruction,
                                  parser)


class ParserTest(unittest.TestCase):
    def test_strips(self):
        self.assertEqual(parser('  mov rax, 20  '), ['mov', 'rax', '20'])

    def test_space_in_arguments(self):
        self.assertEqual(parser('  mov r ax, 2 0  '), ['mov', 'r ax', '2 0'])

    def test_capital(self):
        self.assertEqual(parser('  MOV RDX, 0x17  '), ['mov', 'rdx', '0x17'])

    def test_one_word_commands(self):
        self.assertEqual(parser('cpuid'), ['cpuid'])


class BranchTest(unittest.TestCase):
    """Documentation for BranchTest

    """

    def test_no_command(self):
        with self.assertRaises(InstructionNotFound):
            branch_instruction(parser('BadCommand'))


class AddTest(unittest.TestCase):
    """Documentation for AddTest

    """

    def test_invalid_argument_size(self):
        with self.assertRaises(InstructionNotFound):
            branch_instruction(parser('add rax, rbx, rcx'))
        with self.assertRaises(InstructionNotFound):
            branch_instruction(parser('add rax'))


if __name__ == '__main__':
    unittest.main()
