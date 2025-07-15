import { render, screen } from '@testing-library/react';
import App from './App';

test('renders learn momentic link', () => {
  render(<App />);
  const linkElement = screen.getByText(/learn momentic/i);
  expect(linkElement).toBeInTheDocument();
});
