import { createLazyFileRoute } from '@tanstack/react-router'
import { Container, Title, Text, Button, Stack } from '@mantine/core'

export const Route = createLazyFileRoute('/dashboard')({
  component: Dashboard,
})

function Dashboard() {
  return (
    <Container size="xl" py="xl">
      <Stack gap="lg">
        <Title order={1}>Dashboard</Title>
        <Text size="lg" c="dimmed">
          Your time tracking overview
        </Text>
        <Button variant="filled">
          Start Time Tracking
        </Button>
      </Stack>
    </Container>
  )
}