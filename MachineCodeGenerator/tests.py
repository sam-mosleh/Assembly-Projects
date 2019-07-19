import unittest

from MachineCodeGenerator import parser


class ParserTest(unittest.TestCase):
    def test_strips(self):
        self.assertEqual(parser('  mov rax, 20  '), ['mov', 'rax', '20'])

    def test_space_in_arguments(self):
        self.assertEqual(parser('  mov r ax, 2 0  '), ['mov', 'r ax', '2 0'])

    def test_capital(self):
        self.assertEqual(parser('  MOV RDX, 0x17  '), ['mov', 'rdx', '0x17'])


if __name__ == '__main__':
    unittest.main()
